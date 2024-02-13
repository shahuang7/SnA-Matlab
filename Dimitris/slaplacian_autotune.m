function l = slaplacian_autotune( fName, nS, varargin )
%SLAPLACIAN  Sparse Laplacian matrix
%
% Given a set of nS data points, and the dinstances to nN nearest neighbors
% for each data point, slaplacian computes a sparse, nY by nY symmetric 
% graph Laplacian matrix l.
%
% The input data are supplied in the column vectors yVal and yInd of length
% nY * nN such that 
%
%   yVal( ( i - 1 ) * nN + ( 1 : nN ) ) contains the distances to the
%   nN nearest neighbors of data point i sorted in ascending order, and
%
%   yInd( ( i - 1 ) * nN + ( 1 : nN ) ) contains the indices of the nearest
%   neighbors.
%
%   yVal and yInd can be computed by calling nndist 
%
%   slaplacian admits a number of options passed as name-value pairs
%
%   alpha : normalization, according to Coifman & Lafon
%
%   nAutotune : number of nearest neighbors for autotuning. Set to zero if no
%   autotuning is to be performed
%
%   sigma: width of the Gaussian kernel
% 
%   Modified 08/08/2009

% Load data
load( fName, 'yRow' ); yRow = double( yRow );
load( fName, 'yCol' ); yCol = double( yCol );
load( fName, 'yVal' )

% Default options
Options.alpha     = 1;             % heat-kernel normalization
Options.sigma     = ones( nS, 1 ); % Gaussian width
Options.logfile  = [];             % default logfile (screen)
Options.logfilePermission = 'w';   % overwrite existing logfile
Options = parseargs( Options, varargin{ : } ); % process optional arguments
if ~isempty( Options.logfile )
    logID = fopen( Options.logfile, Options.logfilePermission );
else
    logID = 1;
end

nNZ = numel( yVal );

clk = clock;
fprintf( logID, 'SLAPLACIAN_AUTOTUNE starting on %i/%i/%i %i:%i:%2.1f \n', ...
    clk( 1 ), clk( 2 ), clk( 3 ), clk( 4 ), clk( 5 ), clk( 6 ) );
fprintf( logID, 'Dataset size                = %i \n', nS );
fprintf( logID, 'Number of nonzero elements  = %i \n', nNZ );
fprintf( logID, 'Heat kernel normalization   = %i \n', Options.alpha ); 

% Autotune distances
tic
yVal = yVal ./ Options.sigma( yRow ) ./ Options.sigma( yCol );
t = toc;
fprintf( logID, 'AUTOTUNE: %3.4f \n', t );

% Compute the unnormalized weight matrix
tic
yVal = exp( -yVal ); % yVal is distance ^ 2
t = toc;
fprintf( logID, 'EXP: %3.4f \n', t );
tic
l = sparse( yRow, yCol, yVal, nS, nS, nNZ );
t = toc;
fprintf( logID, 'SPARSE: %3.4f \n', t );

% If required, apply non-isotropic normalization
% Note that the fast index in sparse arrays is the column index,
% so it's faster to perform the sums along the second dimension.
if Options.alpha > 0
    tic
    if Options.alpha ~= 1 
        d = full( sum( l, 2 ) ) .^ Options.alpha;
    else
        d = full( sum( l, 2 ) ); % don't exponentiate if alpha == 1
    end
    t = toc;
    fprintf( logID, 'SUMDALPHA: %3.4f \n', t );
   
    tic
    yVal = yVal ./ d( yRow ) ./ d( yCol );
    t = toc;
    fprintf( logID, 'SCALEDALPHA: %3.4f \n', t );

    tic
    l = sparse( yRow,  yCol, yVal, nS, nS, nNZ );
    t = toc;
    fprintf( logID, 'SPARSE: %3.4f \n' , t );

end

% Form the normalized Laplacian
tic
d = sqrt( full( sum( l, 2 ) ) );
t = toc;
fprintf( logID, 'SUMD: %3.4f \n', t );

tic 
yVal = yVal ./ d( yRow ) ./ d( yCol );
t = toc;
fprintf( logID, 'SCALED: %3.4f \n', t );

tic
l = sparse( yRow, yCol, yVal, nS, nS, nNZ );
t = toc;
fprintf( logID, 'SPARSE: %3.4f \n', t );

tic
l = abs( l + l' ) / 2; % iron out numerical wrinkles
t = toc;
fprintf( logID, 'SYM: %3.4f \n', t );

clk = clock; % Exit gracefully
fprintf( logID, 'SLAPLACIAN_AUTOTUNE finished on %i/%i/%i %i:%i:%2.1f \n', ...
    clk( 1 ), clk( 2 ), clk( 3 ), clk( 4 ), clk( 5 ), clk( 6 ) );
fclose( logID );
return

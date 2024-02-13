function [ lambda, v ] = sembedding_autotune( fName, nS, varargin )
%SEMBEDDING_AUTOTUNE Laplacian eigenfunction embedding using sparse arrays
%   
%   Modified 08/08/2009

% Default options
Options.alpha = 0;                        % heat-kernel normalization
Options.sigma = ones( nS, 1 );            % Gaussian widths
Options.nEigs = 5;                        % number of eigenvectors to compute
Options.laplacianLogfile  = [];           % default logfile for laplacian (screen)
Options.laplacianLogfilePermission = 'w'; % overwrite existing logfile
Options.logfile = [];                     % default logfile
Options.logfilePermission = 'w';          % overwrite existing logfile
Options = parseargs( Options, varargin{ : } );
if ~isempty( Options.logfile )
    logID = fopen( Options.logfile, Options.logfilePermission );
else
    logID = 1;
end

clk = clock;
fprintf( logID, 'SEMBEDDING_AUTOTUNE starting on %i/%i/%i %i:%i:%2.1f \n', ...
    clk( 1 ), clk( 2 ), clk( 3 ), clk( 4 ), clk( 5 ), clk( 6 ) );

fprintf( logID, 'Dataset size                         = %i \n', nS );
fprintf( logID, 'Number of non-trivial eigenfunctions = %i \n', Options.nEigs ); 
fprintf( logID, 'Laplacian logfile: %s \n', Options.laplacianLogfile );

tic
l = slaplacian_autotune( fName, nS, ...
                         'alpha', Options.alpha, ...
                         'sigma', Options.sigma, ... 
                         'logfile', Options.laplacianLogfile, ...
                         'logfilePermission', Options.laplacianLogfilePermission ); 
t = toc;
fprintf( logID, 'SLAPLACIAN_AUTOTUNE: %3.4f \n', t );

tic
[ v, lambda ] = eigs( l, Options.nEigs + 1 );
lambda = diag( lambda );
[ lambda, ix ] = sort( lambda, 'descend' );
v = v( 1 : end, ix );
t = toc;
fprintf( logID, 'EIGS: %3.4f \n', t );

lambda2 = ( 1 - lambda ) / ( 1 - lambda( 2 ) );
for i = 1 : Options.nEigs
    fprintf( logID, 'lambda %i %1.5g \n', i, lambda2( i ) );
end 

clk = clock; % Exit gracefully
fprintf( logID, 'SEMBEDDING_AUTOTUNE finished on %i/%i/%i %i:%i:%2.1f \n', ...
    clk( 1 ), clk( 2 ), clk( 3 ), clk( 4 ), clk( 5 ), clk( 6 ) );
fclose( logID );


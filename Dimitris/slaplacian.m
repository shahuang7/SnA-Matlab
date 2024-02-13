function [ l, sigmaTune ] = slaplacian( fName, nS, varargin )
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
%   Modified 06/07/2009

% Load data
load( fName, 'yRow' ); yRow = double( yRow );
load( fName, 'yCol' ); yCol = double( yCol );
load( fName, 'yVal' )

% Default options
Options.alpha     = 1; % heat-kernel normalization
Options.sigma     = 1; % Gaussian width
Options.nAutotune = 0; % autotuning parameter (not implemented in the
                       % current version) 
Options = parseargs( Options, varargin{ : } );

nNZ = numel( yVal );

% Summary of the calculation to be performed
disp( [ 'Dataset size                = ', int2str( nS ) ] )
disp( [ 'Gaussian width              = ', ...
        num2str( Options.sigma, '%1.4E' ) ] )
disp( [ 'Autotuning parameter        = ', int2str( Options.nAutotune ) ] )
disp( [ 'Number of nonzero elements  = ', int2str( nNZ ) ] )

% If required, compute autotuning distances
if Options.nAutotune > 0
    error( 'Autotuning is not implemented in this version of slaplacian' )    
else
    sigmaTune = Options.sigma;
end
yVal = yVal / sigmaTune ^ 2;

% Compute the unnormalized weight matrix
disp( 'Applying exponential weights...' )
tic
yVal = exp( -yVal ); % yVal is distance ^ 2
l = sparse( yRow, yCol, yVal, nS, nS, nNZ );
toc

% If required, apply non-isotropic normalization
if Options.alpha > 0
    disp( [ 'Performing anisotropic normalization for alpha = ', ...
             num2str( Options.alpha ) ] )
    tic
    if Options.alpha ~= 1 
        d = full( sum( l, 1 ) ) .^ Options.alpha;
    else
        d = full( sum( l, 1 ) ); % don't exponentiate if alpha == 1
    end
    d = d';
    yVal = yVal ./ d( yRow ) ./ d( yCol );
    
    clear d l        % to preserve the memory (AHZ-Aug-2018)                     %AHZ
    
    l = sparse( yRow,  yCol, yVal, nS, nS, nNZ );  % takes large time and memory
    toc
end

% Form the normalized Laplacian
disp( 'Normalizing by the degree matrix...' )
tic
d = sqrt( full( sum( l, 1 ) ) );
d = d';
yVal = yVal ./ d( yRow ) ./ d( yCol );
%
% save yVal_AH.mat yVal -v7.3                                                    %AHZ
%
clear d l            % to preserve the memory (AHZ-Aug-2018)   %AHZ

tic
l = sparse( yRow, yCol, yVal, nS, nS, nNZ );
toc

clear yVal yRow yCol % to preserve the memory (AHZ-Aug-2018)                      %AHZ

tic
l = abs( l + l' ) / 2; % iron out numerical wrinkles
toc
%
% save laplace_AH.mat l -v7.3                                                     %AHZ
%
% Display a message and return
disp( 'slaplacian completed' )
return

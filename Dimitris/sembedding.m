function [ lambda, v ] = sembedding( fName, nS, varargin )
%SEMBEDDING  Laplacian eigenfunction embedding using sparse arrays
%   
%   Modified 02/18/2010

% Default options
Options.alpha = 0;     % heat-kernel normalization
Options.nAutotune = 0; % autotuning parameter
Options.sigma = 1;     % Gaussian width
Options.nEigs = 5;     % number of eigenvectors to compute
Options = parseargs( Options, varargin{ : } );

% Compute the laplacian
l = slaplacian( fName, nS, ...
                         'alpha', Options.alpha, ...
                         'nAutotune', Options.nAutotune, ...
                         'sigma', Options.sigma );

opts.disp = 2;
%opts.p = 44;
%opts.maxit = 200;
[ v, lambda ] = eigs( l, Options.nEigs + 1, 'lm', opts );  % default: lm
lambda = diag( lambda );
% v0=v;
% lambda0=lambda;
% save eigs_lm_sorting_v.mat v0 lambda0
[ lambda, ix ] = sort( lambda, 'descend' );
v = v( 1 : end, ix );

function [ lambda, v ] = embedding( y, varargin )

% Default options
Options.alpha = 0; % normalized graph Laplacian
Options.nAutotune = 0;
Options.sigma = 1;
Options.verbose = true;
Options.useDisk = false;
Options.method = 1;
Options.nEigs = 5;

Options = parseargs( Options, varargin{ : } );

% Compute the laplacian
l = laplacian( y, ...
    'alpha', Options.alpha, ...
    'nAutotune', Options.nAutotune, ...
    'sigma', Options.sigma, ...
    'useDisk', Options.useDisk );

method = Options.method;
nEigs = Options.nEigs + 1;
switch method
    case 1
        [ v, lambda ] = eigs( l, nEigs );
        lambda = diag( lambda );
        [ lambda, ix ] = sort( lambda, 'descend' );
        v = v( 1 : end, ix );
    case 2
        [ v, lambda ] = eig( l );
        lambda = diag( lambda );
        [ lambda, ix ] = sort( lambda, 'descend' );
        lambda = lambda( 1 : nEigs );
        v = v( 1 : end, ix( 1 : nEigs ) );
end

function [ l, sigmaTune ] = laplacian( y, varargin )
%LAPLACIAN Graph Laplacian
%
%  l = laplacian( y, 'alpha', alpha, 'sigma', sigma ) computes a graph 
%  Laplacian matrix associated with the distance matrix y using the 
%  normalization parameter alpha \in [ 0, 1 ] and Gaussian width sigma > 0,
%  as described by Coifman and Lafon, Appl. Comput. Harman. Anal. 21 (2006)
%  5-30.
%
%  [ l, sigmaTune ] = laplacian( y, 'alpha', alpha, 'sigma', sigma, ...
%                                   'nAutotune', nA ) 
%  additionally renormalizes the Gaussian widths for each data point to the
%  distance to their nA-th nearest neighbor (Zelnik-Manor and Perona, NIPS
%  2004). The renormalized Gaussian widths are returned in the column
%  vector sigmaTune. 
%
%  See also SLAPLACIAN, EMBEDDING.
%
%  Modified 06/06/2009 

% Default options
Options.alpha     = 0;     % normalized graph Laplacian
Options.nAutotune = 0;     % no self-tuning
Options.sigma     = 1;     % unit Gaussian width 
Options.useDisk   = false;

Options = parseargs( Options, varargin{ : } );
nY = size( y, 1 );

% If required, do autotuning
if Options.nAutotune > 0
    disp( 'Computing normalization factors for autotuning...' )
    if Options.useDisk
        save laplacian_temp y
    else
        y2 = y;
    end
    y = sort( y );
    sigmaTune = sqrt( y( Options.nAutotune + 1, 1 : end ) ) ...
              * Options.sigma;
    if Options.useDisk
        load laplacian_temp y
    else
        y = y2;
        clear y2
    end
else
    sigmaTune = Options.sigma * ones( nY, 1 );
end

disp( 'Computing the weight matrix...' )
for i = 1 : nY
    y( i, 1 : end ) = y( i, 1 : end ) / sigmaTune( i );
end
for j = 1 : nY
    y( 1 : end, j ) = y( 1 : end, j ) / sigmaTune( j );
end
l = exp( - y );

% If required, apply non-isotropic normalizations
if Options.alpha > 0
    disp( [ 'Performing anisotropic normalization using alpha = ', ...
        num2str( Options.alpha ) ] )
    d = sum( l, 2 ) .^ Options.alpha;
    for i = 1 : nY
            l( i, 1 : end ) = l( i, 1 : end ) / d( i );
    end
    for j = 1 : nY
            l( 1 : end, j ) = l( 1 : end, j ) / d( j );
    end
end

disp( 'Normalizing by the degree matrix...' )
d = sum( l,  2 );
d = sqrt( d );
for i = 1 : nY
    l( i, 1 : end ) = l( i, 1 : end ) / d( i );
end
for j = 1 : nY
    l( 1 : end, j ) = l( 1 : end, j ) / d( j );
end

l = abs( ( l' + l ) / 2 ); % iron out numerical wrinkles

function y = dmat( x1, x2 )
%DMAT distance matrix
%
%   Given two clouds of points in nD-dimensional space, represented by the 
%   arrays x1 and x2, respectively of size [ nD, nX1 ] and [ nD, nX2 ], 
%   y = dmat( x1, x2 ) returns the distance matrix y of size ( nX1. nX2 ) 
%   such that 
%
%   y( i, j ) = norm( x1( : , i ) - x2( :, j ) ) ^ 2.
%
%   The syntax y = dmat( x1 ) is equivalent to y = dmat( x1, x2 )
%    
%   Modified 03/23/2009

switch nargin
    
    case 1
    
        nX1 = size( x1, 2 );
        y = repmat( sum( x1 .^ 2, 1 ), nX1, 1 );
        y = y - x1' * x1;
        y = y + y';
        y = abs( y + y' ) / 2; % Iron-out numerical wrinkles

    case 2
        
        nX1 = size( x1, 2 );
        nX2 = size( x2, 2 );
        
        
        y = repmat( sum( x1 .^ 2, 1 )', 1, nX2 );
        y = y + repmat( sum( x2 .^ 2, 1 ), nX1, 1 );
        y = y - 2 * x1' * x2;

end

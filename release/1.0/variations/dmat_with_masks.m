function y = dmat_with_masks( x1, x2, m1, m2 )
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
%
%DMAT_WITH_MASKS
%
%   Modified from DMAT. Different pixels are masked out from each vector.
%   Squared distance between two vectors is defined as the sum of element-wise
%   squared differences over elements that are common to both vectors, normalized
%   to the total number of elements.
%   m1 has the same size as x1, and m1(dd,ii) = 1 (0) if x1(dd,ii) is ON (OFF).
%   m2 has the same size as x2, and m2(dd,jj) = 1 (0) if x2(dd,jj) is ON (OFF).
%
%   See May 22, 2015 writeup for derivation.
%
%   Modified 05/26/2015
%   Copyright (c) Russell Fung 2015
%

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

    case 4
        
        nD = size( x1, 1 );
        y = (x1.^2)'*m2-2*x1'*x2+m1'*(x2.^2);
        y = y./(m1'*m2)*nD;

end

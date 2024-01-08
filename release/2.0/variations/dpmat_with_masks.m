function y = dpmat_with_masks( x1, x2, m1, m2 )
%DPMAT dot-product matrix
%
%   Given two clouds of points in nD-dimensional space, represented by the 
%   arrays x1 and x2, respectively of size [ nD, nX1 ] and [ nD, nX2 ], 
%   y = dpmat( x1, x2 ) returns the dot-product matrix y of size ( nX1, nX2 ) 
%   such that 
%
%   y( i, j ) = x1( : , i ) . x2( :, j ).
%
%   The syntax y = dpmat( x1 ) is equivalent to y = dpmat( x1, x1 )
%    
%   Modified from Dimitris Giannakis' dmat
%
%DPMAT_WITH_MASKS
%
%   Modified from DPMAT. Different pixels are masked out from each vector.
%   Dot products between two vectors is defined as the sum of element-wise
%   products over elements that are common to both vectors, normalized
%   to the total number of elements.
%   m1 has the same size as x1, and m1(dd,ii) = 1 (0) if x1(dd,ii) is ON (OFF).
%   m2 has the same size as x2, and m2(dd,jj) = 1 (0) if x2(dd,jj) is ON (OFF).
%
% Programmed 25th December 2016
% Copyright (c) Russell Fung 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch nargin
    
    case 1
    
        y = x1' * x1;

    case 2
        
        y = x1' * x2;

    case 4
        
        nD = size( x1, 1 );
        y = x1' * x2;
        y = y./(m1'*m2)*nD;

end

function y = dpmat( x1, x2 )
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
% Programmed 21st February 2014
% Comments and codes last updated March 2014
% Copyright (c) Russell Fung 2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch nargin
    
    case 1
    
        y = x1' * x1;

    case 2
        
        y = x1' * x2;

end

function y = dmatCtf( x1, c1, x2, c2 )
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
%   CTF correction added 11/25/2010 by Peter Schwander, UWM

switch nargin
    
    case 2
    
        %nX1 = size( x1, 2 );
        %y = repmat( sum( x1 .^ 2, 1 ), nX1, 1 );
        %y = y - x1' * x1;
        %y = y + y';
        %y = abs( y + y' ) / 2; % Iron-out numerical wrinkles
        
        a  = (abs(c1).^2)'*(abs(x1).^2);
        x1 = conj(c1).*x1;
        y = (x1'*x1);
        y = a + a' - 2*real(y);
        y = y/size(x1,1);

    case 4
        
        %nX1 = size( x1, 2 );
        %nX2 = size( x2, 2 );
        
        
        %y = repmat( sum( x1 .^ 2, 1 )', 1, nX2 );
        %y = y + repmat( sum( x2 .^ 2, 1 ), nX1, 1 );
        %y = y - 2 * x1' * x2;
        
        a  = (abs(c1).^2)'*(abs(x2).^2);
        a  = a + ((abs(c2).^2)'*(abs(x1).^2))';
        x1 = conj(c1).*x1;
        x2 = conj(c2).*x2;
        y = (x1'*x2);
        y = a - 2*real(y);
        
        y = y/size(x1,1);

end

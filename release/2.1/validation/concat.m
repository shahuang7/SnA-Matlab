function Tc=concat(T,c)
%
% Tc=concat(T,c)
%
% performs c-fold concatenation of the matrix T, and returns the result in Tc.
%
% As part of the validation code for the shift-and-add library, this code
% serves to specify/ document the convention for concatenation.
%
% copyright (c) Russell Fung 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  [D,N] = size(T);
  Tc = zeros(D*c,N-c);
  for j=0:c-1
    Tc(j*D+[1:D],:) = T(:,[c+1:N]-j);
  end
% end function concat

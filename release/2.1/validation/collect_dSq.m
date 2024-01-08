function dSq=collect_dSq(fileName_template,read_format,N,n,a)
%
% dSq=collect_dSq(fileName_template,read_format,N,n,a)
%
% collects the elements of the matrix of squared distances from files, and
% returns the matrix in dSq.
%
% copyright (c) Russell Fung 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  numRow = ceil((N-a)/n);
  numCol = numRow;
  dSq = zeros(numRow*n);
  for row=1:numRow
    j0 = (row-1)*n+1;
    j1 = j0+n-1;
    for col=1:row-1
      i0 = (col-1)*n+1;
      i1 = i0+n-1;
      dSq(j0:j1,i0:i1) = dSq(i0:i1,j0:j1)';
    end
    for col=row:numCol
      i0 = (col-1)*n+1;
      i1 = i0+n-1;
      dSq(j0:j1,i0:i1) = read_dSq(fileName_template,read_format,a,row,col,n);
    end
  end
  dSq = dSq(1:N-a,1:N-a);
% function collect_dSq

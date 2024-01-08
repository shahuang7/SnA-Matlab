function dSq=read_dSq_sparse(fileName_template,read_format,a,row,col,n)
% 
% dSq = read_dSq_sparse(fileName_template,read_format,a,row,col,n)
% 
% same as read_dSq(fileName_template,read_format,a,row,col,n), except
% -- Matlab sparse matrix "dSq" is read in.
% -- "missing" elements are filled in with inf.
% -- diagonal elements of diagonal block are filled in with 0.
% -- parameter "read_format" is ignored.
% 
% Copyright (c) Russell Fung 2019
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  fileName = sprintf(fileName_template,a,row,col);
  load(fileName,'dSq')
  dSq = full(dSq);
  dSq(dSq==0) = inf;
  if (row==col)
    for jj=1:n
      dSq(jj,jj) = 0;
    end
  end
  
% function read_dSq_sparse

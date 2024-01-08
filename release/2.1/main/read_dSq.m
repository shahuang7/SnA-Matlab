function dSq=read_dSq(fileName_template,read_format,a,row,col,n)
%
% dSq = read_dSq(fileName_template,read_format,a,row,col,n)
%
% reads a block of the matrix of squared distances from a file.
%
% fileName_template --- format string for the name of the input file,
%   must take 3 integer parameters: a, row, col.
% read_format --- 'single' or 'double'.
% a --- current concatenation parameter.
% row, col --- the row and column indices of the block.
% n --- the size of the submatrix (block) is n x n.
% dSq --- the output submatrix (block).
%
% If the file specified by "fileName_template", "a", "row" and "col"
% does not exist, a zero matrix is returned.
%
% example:
%   dSq=read_dSq('dSq_N41180_n2000_c%d_row%d_col%d.dat','double',2,1,5,2000);
%
% Programmed 28th January 2014
% Comments and codes last updated March 2014
% Copyright (c) Russell Fung 2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  fileName = sprintf(fileName_template,a,row,col);
  fid = fopen(fileName,'r');
  if (fid<0)
    dSq = zeros(n);
    return
  end
  dSq = fread(fid,[n,n],read_format);
  fclose(fid);
% function read_dSq

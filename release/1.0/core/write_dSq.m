function write_dSq(fileName_template,write_format,a,row,col,dSq)
%
% write_dSq(fileName_template,write_format,a,row,col,dSq)
%
% writes a block of the matrix of squared distances into a file.
%
% fileName_template --- format string for the name of the output file,
%   must take 3 integer parameters: a, row, col.
% write_format --- 'single' or 'double'.
% a --- current concatenation parameter.
% row, col --- the row and column indices of the block.
% dSq --- the submatrix (block) to be written.
%
% example:
%   write_dSq('dSq_N41180_n2000_c%d_row%d_col%d.dat','double',2,1,5,dSq)
%
% Programmed 27th January 2014
% Comments and codes last updated March 2014
% Copyright (c) Russell Fung 2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  fileName = sprintf(fileName_template,a,row,col);
  fid = fopen(fileName,'w');
  fwrite(fid,dSq,write_format);
  fclose(fid);
% function write_dSq

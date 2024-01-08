function write_dSq_sparse(fileName_template,write_format,a,row,col,dSq,nN)
% 
% write_dSq_sparse(fileName_template,write_format,a,row,col,dSq,nN)
% 
% same as write_dSq(fileName_template,write_format,a,row,col,dSq), except
% -- only candidates for nN nearest-neighbor dSq are written out;
% -- matrix is saved in sparse format.
% -- parameter "write_format" is ignored.
% 
% Copyright (c) Russell Fung 2019
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  fileName = sprintf(fileName_template,a,row,col);
  dSq = dSq.*sparse(mask_nN_smallest_2D(dSq,nN));
  save(fileName,'dSq','-v7.3')
  
% function write_dSq_sparse

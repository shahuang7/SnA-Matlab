function status=elementwise_normalize(param,numWorker,workerID)
%
% elementwise_normalize(param,numWorker,workerID)
%
% performs normalization for the matrix of squared distances (or dot
% products) for a set of vectors, by dividing said matrix, elementwise,
% by the matrix of dot products of the masks, and writes the results
% into files.
%
% param.{fileName_template_num,fileName_template_denom,
%   fileName_template_corrected,io_format,c,n} must be defined.
%
% param.fileName_template --- format string for the name(s) of the
% input/output file(s), must take 3 integer parameters: a, row, col (in that
% order) which are, repectively, the current concatenation parameter,
% and the row and column indices of the block.
%
% param.io_format -- 'single' or 'double'.
%
% param.c -- concatenation parameter.
%
% param.n --- each input/output file contains an n x n block of the matrix of
%   dot products.
%
% For serial mode, set numWorker=1 and workerID=0.
%
% For parallel mode, set numWorker to be the number of workers, and
%   workerID to be any integer from 0 to numWorker-1.
%
% Parallelization by treating the problem as embarrassingly
% parallel with no duplication of efforts.
%
% Each worker is responsible for some number of rows, with no overlaps.
%
% Programmed 15th March 2016
% Copyright (c) Russell Fung 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  fileName_template_num       = param.fileName_template_num;
  fileName_template_denom     = param.fileName_template_denom;
  fileName_template_corrected = param.fileName_template_corrected;
  io_format = param.io_format;
  concatOrder = param.c;
  n = param.n;
  
  param.a = concatOrder;
  param.b = 0;
  myRows = get_row_col_range(param,numWorker,workerID);
  
  for row=myRows
    for col=get_row_col_range(param,numWorker,workerID,row);
      numerator   = read_dSq(fileName_template_num,  io_format,concatOrder,row,col,n);
      denominator = read_dSq(fileName_template_denom,io_format,concatOrder,row,col,n);
      denominator(denominator==0) = 1;
      corrected = bsxfun(@rdivide,numerator,denominator);
      write_dSq(fileName_template_corrected,io_format,concatOrder,row,col,corrected);
    end
  end
  status = 1;
% end function elementwise_normalize

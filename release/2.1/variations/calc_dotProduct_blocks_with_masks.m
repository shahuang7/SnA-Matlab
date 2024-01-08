function calc_dotProduct_blocks_with_masks(param,numWorker,workerID)
%
% calc_dotProduct_blocks_with_masks(param,numWorker,workerID)
%
% calculates the matrix of dot products for a set of vectors, and
% writes the results into files.
%
% param.{n,N,rawDataFile,rawDataVar,fileName_template,io_format} must be
% defined.
%
% param.n --- each output file contains an n x n block of the matrix of
%   dot products.
%
% param.N --- the total number of data vectors.
%
% param.rawDataFile --- the name of the Matlab binary file with the
%   data vectors.
%
% param.rawDataVar --- the name of the Matlab variable with the data
%   vectors, rawDataVar is (number of vectors) x (number of pixels).
%
% param.maskFile --- the name of the Matlab binary file with the
%   mask vectors.
%
% param.maskVar --- the name of the Matlab variable with the mask
%   vectors, maskVar is (number of vectors) x (number of pixels).
%
% param.fileName_template --- format string for the name(s) of the
% output file(s), must take 3 integer parameters: a, row, col (in that
% order) which are, repectively, the current concatenation parameter,
% and the row and column indices of the block.
%
% param.io_format -- 'single' or 'double'.
%
% For serial mode, set numWorker=1 and workerID=0.
%
% For parallel mode, set numWorker to be the number of workers, and
%   workerID to be any integer from 0 to numWorker-1.
%
% Parallelization by treating the problem as embarrassingly
% parallel with some duplication of efforts.
%
% Each worker is responsible for some number of rows, with
% overlaps determined by the concatenation parameter.
%
% Programmed 25th December 2016
% Copyright (c) Russell Fung 2016
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  n = param.n;
  N = param.N;
  D = param.D;
  rawDataFile = param.rawDataFile;
  rawDataVar = param.rawDataVar;
  maskFile = param.maskFile;
  maskVar = param.maskVar;
  fileName_template = param.fileName_template;
  io_format = param.io_format;
  load(rawDataFile,rawDataVar)
  load(maskFile,maskVar)
  command = sprintf('%s=%s'';',rawDataVar,rawDataVar);
  eval(command);
  command = sprintf('%s=double(%s)'';',maskVar,maskVar);
  eval(command);
  
  myRows = get_row_col_range(param,numWorker,workerID);
  
  for row=myRows
    %
    % the first sample is skipped
    %
    j0 = (row-1)*n+2;
    j1 = j0+n-1;
    j1 = min(j1,N);
    command = sprintf('dataJ = %s(1:D,j0:j1);',rawDataVar);
    eval(command);
    command = sprintf('maskJ = %s(1:D,j0:j1);',maskVar);
    eval(command);
    for col=get_row_col_range(param,numWorker,workerID,row);
      %
      % the first sample is skipped
      %
      i0 = (col-1)*n+2;
      i1 = i0+n-1;
      i1 = min(i1,N);
      if (col>row)
        command = sprintf('dataI = %s(1:D,i0:i1);',rawDataVar);
        eval(command);
        command = sprintf('maskI = %s(1:D,i0:i1);',maskVar);
        eval(command);
        dSq = zeros(n);
        dSq(1:j1-j0+1,1:i1-i0+1) = dpmat_with_masks(dataJ.*maskJ,dataI.*maskI,maskJ,maskI);
      else
        dSq = zeros(n);
        dSq(1:j1-j0+1,1:i1-i0+1) = dpmat_with_masks(dataJ.*maskJ,dataJ.*maskJ,maskJ,maskJ);
      end
      write_dSq(fileName_template,io_format,1,row,col,dSq);
    end
  end
% end function calc_dotProduct_blocks_with_masks

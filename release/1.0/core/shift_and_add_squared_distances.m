function shift_and_add_squared_distances(param,numWorker,workerID)
%
% shift_and_add_squared_distances(param,numWorker,workerID)
%
% calculates the matrix of squared distances for a higher concatenation
% parameter from the matrices of squared distances for two lower
% concatenation parameters through shifting-and-adding.
%
% param.{a,b,n,N,fileName_template,io_format} must be defined.
%
% param.a, param.b --- the input concatenation parameters for
% shifting-and-adding.
%
% param.n --- each input/output file contains an n x n block of the
%   matrix of squared distances.
%
% param.N --- the total number of unconcatenated data vectors.
%
% param.fileName_template --- format string for the name(s) of the
% input/output file(s), must take 3 integer parameters: a, row, col
% (in that order) which are, respectively, the concatenation
% parameter, and the row and column indices of the block.
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
% Programmed 11th February 2014
% Comments and codes last updated February 2014
% Parallelized 28th August 2015
% Copyright (c) Russell Fung 2014-2015
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  a = param.a;
  b = param.b;
  n = param.n;
  N = param.N;
  fileName_template = param.fileName_template;
  io_format = param.io_format;
  %
  % for c-fold concatenation, c samples are removed from the left.
  %
  numRow = ceil((N-a-b)/n);
  numCol = numRow;
  blockOffset = floor(a/n);
  %
  % blockOffset is the number of blocks (or files) to skip over while
  % reading the matrix of squared distances for concatenation parameter b.
  %
  shift = mod(a,n);
  %
  % shift is the number of vectors within a file to skip over while
  % reading the matrix of squared distances for concatenation parameter b.
  %
  
  myRows = get_row_col_range(param,numWorker,workerID);
  
  if (~shift)
    for row=myRows
      for col=get_row_col_range(param,numWorker,workerID,row)
        dSq_a = read_dSq(fileName_template,io_format,a,row,col,n);
        dSq_b = read_dSq(fileName_template,io_format,b,...
          row+blockOffset,col+blockOffset,n);
        dSq = dSq_a+dSq_b;
        write_dSq(fileName_template,io_format,a+b,row,col,dSq);
      end
    end
  else
    for row=myRows
      for col=get_row_col_range(param,numWorker,workerID,row)
        dSq_a = read_dSq(fileName_template,io_format,a,row,col,n);
        %
        % squared distances for concatenation parameter b come from
        % four files: NW,NE,SW,SE
        %
        dSq_b_NW = read_dSq(fileName_template,io_format,b,...
          row+blockOffset,col+blockOffset,n);
        dSq_b_NW = dSq_b_NW(shift+1:end,shift+1:end);
        dSq_b_NE = read_dSq(fileName_template,io_format,b,...
          row+blockOffset,col+blockOffset+1,n);
        dSq_b_NE = dSq_b_NE(shift+1:end,1:shift);
        if (row+1>col)
          %
          % only blocks in the upper triangle exist
          %
          dSq_b_SW = read_dSq(fileName_template,io_format,b,...
            col+blockOffset,row+blockOffset+1,n)';
        else
          dSq_b_SW = read_dSq(fileName_template,io_format,b,...
            row+blockOffset+1,col+blockOffset,n);
        end
        dSq_b_SW = dSq_b_SW(1:shift,shift+1:end);
        dSq_b_SE = read_dSq(fileName_template,io_format,b,...
          row+blockOffset+1,col+blockOffset+1,n);
        dSq_b_SE = dSq_b_SE(1:shift,1:shift);
        dSq_b = [dSq_b_NW,dSq_b_NE;dSq_b_SW,dSq_b_SE];
        dSq = dSq_a+dSq_b;
        write_dSq(fileName_template,io_format,a+b,row,col,dSq);
      end
    end
  end
% end function shift_and_add_squared_distances

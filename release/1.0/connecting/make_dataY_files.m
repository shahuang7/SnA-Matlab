% make_dataY_files
%
% takes the results of shifting-and-adding, and reformats it for
% DG's scriptDisanceSymmetrization.m
%
% N --- the total number of unconcatenated data vectors
% n --- each input file contains an n x n block of the matrix of squared distances
% concatOrder --- concatenation parameter
% nN --- matrix of squared distances is truncated at nN nearest neighbors
% nB --- each dataY file contains the squared distances of nB vectors
% numFile --- the number of dataY files
% io_format --- 'single' or 'double'
% directory --- the output of shifting-and-adding is stored here
% fileName_template --- the format string for the names of the input files
%
% Programmed 17th February 2014
% Comments and codes last updated February 2015
% Copyright (c) Russell Fung 2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% N = 
% n = 
% concatOrder = 
% nN =             %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% nB =             %%% supplied by calling subroutine %%%
% numFile =        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% io_format = 
% directory = 
% fileName_template = 
numRow = ceil((N-concatOrder)/n);
%
% for c-fold concatenation, c samples are removed from the left.
%
numCol = numRow;
yVal_full = zeros((N-concatOrder)*nN,1);
yInd_full = zeros((N-concatOrder)*nN,1);
%
% yVal_full stores the nN nearest-neighbor squared distances for (N-c) vectors
% yInd_full stores the corresponding global indices
%
tAll = tic;
for row=1:numRow
  yVal_row = [];
  yInd_row = [];
  tRow = tic;
  for col=1:numCol
    if (col<row)
      dSq = read_dSq([directory fileName_template],io_format,concatOrder,col,row,n)';
    else
      dSq = read_dSq([directory fileName_template],io_format,concatOrder,row,col,n);
    end
    n1 = n;
    if (col==numCol)
      n1 = mod(N-concatOrder,n);
      if (n1==0), n1 = n; end
    end
    %
    % watch out for fake zeros in the last column block
    %
    yVal_temp = [yVal_row dSq(:,1:n1)];
    yInd_temp = [yInd_row bsxfun(@plus,zeros(n,1),(col-1)*n+[1:n1])];
    %
    % for each row, yVal_row carries the sorted nN nearest-neighbor
    % squared distances up to and including the last column block,
    % yInd_row carries the global indices of these neighbors
    %
    % yVal_temp appends the squared distances from the current
    % column block, yInd_temp appends the corresponding global
    % indices
    %
    [yVal_temp,order] = sort(yVal_temp,2);
    yVal_row = yVal_temp(:,1:nN);
    order = order(:,1:nN);
    %
    % yVal_row now carries the sorted nN nearest-neighbor
    % squared distances up to and including the current column
    % block
    %
    % since sorting is carried out with respect to the second
    % index, order carries the second indices of the elements
    % of interest in yInd_temp
    %
    rowSkip = size(yInd_temp,2);
    lookupIndex = bsxfun(@plus,([1:n]'-1)*rowSkip,order);
    %
    % lookupIndex carries the ROW-MAJOR 1D indices to read
    % yInd_temp
    %
    yInd_temp = reshape(yInd_temp',[],1);
    lookupIndex = reshape(lookupIndex',[],1);
    yInd_row = reshape(yInd_temp(lookupIndex),nN,[])';
    %
    % yInd_row now carries the global indices corresponding
    % to yVal_row
    %
  end
  n1 = n;
  if (row==numRow)
    n1 = mod(N-concatOrder,n);
    if (n1==0), n1 = n; end
  end
  %
  % watch out for fake zeros in the last row block
  %
  yVal_full((row-1)*n*nN+[1:n1*nN]) = reshape(yVal_row(1:n1,:)',[],1);
  yInd_full((row-1)*n*nN+[1:n1*nN]) = reshape(yInd_row(1:n1,:)',[],1);
  toc(tRow)
end
for jj=1:numFile
  yInd = yInd_full((jj-1)*nB*nN+[1:nB*nN]);
  yVal = yVal_full((jj-1)*nB*nN+[1:nB*nN]);
  fileName = sprintf('dataY_nS%d_nN%d_iB%d.mat',N-concatOrder,nN,jj);
  save(fileName,'yInd','yVal','-v7.3');
end
toc(tAll)

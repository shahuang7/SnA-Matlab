function M=mask_nN_smallest_per_row(X,nN)
  [numRow,~] = size(X);
  [~,col_ind]= sort(X,2,'ascend');
  X(bsxfun(@plus,(col_ind(:,nN+1:end)-1)*numRow,[1:numRow]')) = inf;
  M = ~isinf(X);

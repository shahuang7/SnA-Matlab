function status=test_dSq_sparse_read_write(n,nN,isdiagonal)
  
  addpath('/home/sna/release/2.1/main')
  fileName_template = 'test_dSq_sparse_c%d_row%d_col%d.mat';
  write_format = []; read_format = [];
  
  X = rand(n);
  a = randi(1000); row = randi(1000); col = randi(1000);
  while (row==col), col = randi(1000); end
  if (isdiagonal)
    X = 0.5*(X+X');
    X = X-diag(diag(X));
    col = row;
  end
  write_dSq_sparse(fileName_template,write_format,a,row,col,X,nN)
  Y = read_dSq_sparse(fileName_template,read_format,a,row,col,n);
  
% do the same thing a different, more transparent way
  X_row_sparse = X;
  for row=1:n
    [~,order] = sort(X(row,:));
    X_row_sparse(row,order(nN+1:end)) = nan;
  end
  X_col_sparse = X;
  for col=1:n
    [~,order] = sort(X(:,col));
    X_col_sparse(order(nN+1:end),col) = nan;
  end
  X_sparse = zeros(2,n,n);
  X_sparse(1,:,:) = X_row_sparse;
  X_sparse(2,:,:) = X_col_sparse;
  X_sparse = squeeze(nanmean(X_sparse,1));
  X_sparse(isnan(X_sparse)) = inf;
  
  agree = Y==X_sparse;
  status = all(agree(:));
  if ~status
    save('dSq_sparse_read_write_failure.mat','X','X_sparse','Y','n','nN','isdiagonal','row','col')
  end

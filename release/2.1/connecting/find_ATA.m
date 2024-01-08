function ATA=find_ATA(ell,mu_psi,fileName_template,read_format,N,n,concatOrder)
  nS = N-concatOrder;
  ATA = zeros(ell+1);
  %
  % A^T A = (mu psi)^T (X^T X) (mu psi)
  % is calculated as two inner products from the point-of-view of (X^T X)
  %
  % row index of (X^T X) keeps track of the inner product to the left
  % column index of (X^T X) keeps track of the inner product to the right
  %
  % numFiles & fileNum used to keep track of the progress of the calculation
  %
  numRow = ceil((N-concatOrder)/n);
  numCol = numRow;
  numFiles = numRow*numCol;
  fileNum = 0;
  for row=1:numRow
  %
  % the inner product to the left
  %
  % calculate one block row of (X^T X) (mu psi), multiply that to the
  % corresponding column block of (mu psi)^T, and accumulate
  %
    j0 = (row-1)*n+1;
    j1 = j0+n-1;
    j1 = min(j1,nS);
    XcTXc_mu_psi = zeros(n,ell+1);
    %
    % XcTXc_mu_psi is one block row of (X^T X) (mu psi)
    %
    for col=1:numCol
    %
    % the inner product to the right
    %
    % read the (row,column) block of (X^T X), multiply that to the corresponding
    % row block of (mu psi), and accumulate
    %
      i0 = (col-1)*n+1;
      i1 = i0+n-1;
      i1 = min(i1,nS);
      if (row>col)
        XcTXc = read_dSq(fileName_template,read_format,concatOrder,col,row,n)';
      else
        XcTXc = read_dSq(fileName_template,read_format,concatOrder,row,col,n);
      end
      if (col==numCol)
        n1 = mod(nS-1,n)+1;
        XcTXc = XcTXc(:,1:n1);
      end
      XcTXc_mu_psi = XcTXc_mu_psi+XcTXc*mu_psi(i0:i1,:);
      fileNum = fileNum+1;
      disp(['processing files ' num2str(round(fileNum/numFiles*1000)/10) '% ...'])
    end
    if (row==numRow)
      n1 = mod(nS-1,n)+1;
      XcTXc_mu_psi = XcTXc_mu_psi(1:n1,:);
    end
    ATA = ATA+mu_psi(j0:j1,:)'*XcTXc_mu_psi;
  end
% end find_ATA

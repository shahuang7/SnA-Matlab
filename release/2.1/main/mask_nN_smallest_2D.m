function M=mask_nN_smallest_2D(X,nN)
  M1 = mask_nN_smallest_per_row(X,nN);
  M2 = mask_nN_smallest_per_row(X',nN)';
  M = M1|M2;

function [U,S,V]=extract_topos_chronos(ell,X1,dataPsi,read_format,D,N,n,concatOrder,num_copy)
  fileName_prefix = ['dp_N' num2str(N) '_n' num2str(n)];
  %
  % shift-and-add results for dot products go here
  %
  directory = ['dp_N' num2str(N) '_n' num2str(n) '_c' num2str(concatOrder) '/'];
  fileName_template = [directory fileName_prefix '_c%d_row%d_col%d.dat'];
  
  load(dataPsi,'psi','mu');
  psi = double(psi);
  mu = double(mu);
  nS = size(psi,1);
  psi = [ones(nS,1) psi(:,1:ell)];
  mu_psi = bsxfun(@times,mu,psi);
  
  ATA = find_ATA(ell,mu_psi,fileName_template,read_format,N,n,concatOrder);
  
  [EV,S_sq] = eig(ATA);
  [S_sq,order] = sort(diag(S_sq),'descend');
  V = EV(:,order);
  
  S = sqrt(S_sq);
  invS = diag(1./S);
  S = diag(S);
  
  U = zeros(D*num_copy,ell+1);
  for cc=1:num_copy
    U((cc-1)*D+[1:D],:) = X1(:,[concatOrder+1:end]-cc+1)*mu_psi*V*invS;
  end
  
  V = psi*V;
% end function extract_topos_chronos

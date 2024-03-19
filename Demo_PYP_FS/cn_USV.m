addpath(pwd, ...
    '~/Data/huang229/SnA-Matlab/release/2.0/connecting/', ...
    '~/Data/huang229/SnA-Matlab/release/2.0/core/', ...
    '~/Data/huang229/SnA-Matlab/release/2.0/validation/', ...
    '~/Data/huang229/SnA-Matlab/release/2.0/variations/')

DataFile = '~/Data/huang229/PYP_fs_nS152677/dataPYP_femto_int_sortdelay_unifdelay_DRL_SCL_BST_nS152677_nBrg21556.mat';
DataVar = 'T_drl_scl_bst';
load(DataFile,DataVar);
command = sprintf('%s=%s'';','X1',DataVar);
eval(command);
read_format='double';
D = 21556;
N = 152677;
numTasks = 16;
concatOrder = 32768;
n = ceil((N-concatOrder)/numTasks);
ell = 10;
dataPsi = '../eig.mat';
num_copy = 2;

fileName_template = ['./dp_chunks/dp_N' num2str(N) '_n' num2str(n) '_c%d_row%d_col%d.dat'];
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
save('uv.mat','U','S','V','-v7.3');

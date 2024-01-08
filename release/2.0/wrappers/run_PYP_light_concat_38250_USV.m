ell = 10;
load('PYP_152677_21556.mat','T');
X1 = T';
sigmaOpt = 584240996.0877;
dataPsi_template = '../parallel_Embed/dataPsi_nS114427_nN500_nA0_sigma%s_nEigs30.mat';
read_format = 'double';
D = 21556;
N = 152677;
n = 3815;
concatOrder = 38250;
num_copy = 100;

sigmaList0 = 10.^linspace(log10(sigmaOpt/10),log10(sigmaOpt),7);
sigmaList1 = 10.^linspace(log10(sigmaOpt),log10(sigmaOpt*10),10);
sigmaList = unique([sigmaList0 sigmaList1]);

for jj=1:16
  sigma = sigmaList(jj);
  dataPsi = sprintf(dataPsi_template,num2str(sigma,'%.4f'));
  [U,S,V] = extract_topos_chronos(ell,X1,dataPsi,read_format,D,N,n,concatOrder,num_copy);
  fileNameUSV = ['SVD_' num2str(sigma,'%.4f') '_chronosVer1.mat'];
  save(fileNameUSV,'U','S','V','-v7.3')
  plot_USV_results(sigma,num_copy)
end

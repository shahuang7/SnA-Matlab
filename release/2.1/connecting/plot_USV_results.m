function plot_USV_results(sigma,num_copy)
  fileNameUSV = ['SVD_' num2str(sigma,'%.4f') '_chronosVer1.mat'];
  load(fileNameUSV,'S')
  ell = size(S,1)-1;
  x = [1:1+ell];
  y = diag(S);
  h = figure(1);
  set(h,'color','w')
  hsp = subplot(1,1,1);
  myXLabel = 'singular value#';
  myYLabel = 'singular value';
  myTitle = sprintf('SVD results, \\sigma=%6.4f',sigma);
  plotRF(hsp,x,y,myXLabel,myYLabel,myTitle,'b-o')
  logymin = floor(log10(min(diag(S))));
  logymax = ceil(log10(max(diag(S))));
  set(hsp,'yscale','log');
  set(hsp,'yTick',10.^[logymin:logymax]);
  y_min = min(y);
  y_max = max(y);
  y_range = y_max/y_min;
  y_min = y_min/y_range^0.1;
  y_max = y_max*y_range^0.1;
  set(hsp,'ylim',[y_min,y_max])
  fileNameJPG = ['sigma_' num2str(sigma,'%.4f') '_singular_values.jpg'];
  export_fig('-jpeg','-r200',fileNameJPG)
  
  close all
  plot_averaged_topos(sigma,num_copy);
  
  close all
  plot_chronos(sigma);
% end function plot_USV_results

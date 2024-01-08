function plot_chronos(sigma)
  fileNameUSV = ['SVD_' num2str(sigma,'%.4f') '_chronosVer1.mat'];
  load(fileNameUSV,'V');
  fileNameJPG = ['chronos_sigma_' num2str(sigma,'%.4f') '_plot_%d.jpg'];
  plotAutoPage(0,V,6,'','V_{%d}','chronos',fileNameJPG);
% end function plot_chronos

function plotToF_panel(h,ToF,numStops,nn,panelLabel)
  D = numel(ToF);
  vOffset = D/4;
  t0 = min(ToF);
  t1 = max(ToF);
  ToF = ToF-min(ToF);
  ToF = ToF/max(ToF)*vOffset;
  offset = (nn-1)*vOffset;
  figure(h)
  hold on
  plot(ToF+offset,'lineWidth',2)
  plot([0 D],nn*vOffset*[1 1],'k-','lineWidth',2)
  text(-D/4,(nn-0.5)*vOffset,panelLabel,'fontSize',15)
  if (nn==1)
    set(h,'color','w');
    axis equal, axis([0 D 0 numStops*vOffset])
    hCA = get(h,'currentAxes');
    set(hCA,'box','on','lineWidth',2,'fontSize',15);
    set(hCA,'xTick',[])
    set(hCA,'yTick',[])
  end
  return
% end function plotToF_panel

function prevPlot=plotAutoPage(prevPlot,X,maxPanel,myXlabel,myYlabel,myTitle,myFileName)
  numPanels = size(X,2);
  numPages = 1;
  numPanelsPerPage = min(numPanels,maxPanel);
  if (numPanels>maxPanel)
    numPages = ceil(numPanels/maxPanel);
    numPanelsPerPage = ceil(numPanels/numPages);
  end
  for kk=1:numPanels
    pageNum = ceil(kk/numPanelsPerPage);
    panelNum = kk-(pageNum-1)*numPanelsPerPage;
    h = figure(prevPlot+pageNum);
    plotToF_panel(h,X(:,kk),numPanelsPerPage,panelNum,sprintf(myYlabel,kk))
  end
  for pageNum=1:numPages
    h = figure(prevPlot+pageNum);
    xlabel(myXlabel)
    title(myTitle,'fontSize',15)
    pageJPG = sprintf(myFileName,pageNum);
    export_fig('-r200',pageJPG)
  end
  prevPlot = prevPlot+numPages;
  return
% end function plotAutoPage

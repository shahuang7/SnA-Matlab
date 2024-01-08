function plotRF(hAxis,x,y,xlabelText,ylabelText,titleText,lineStyle)
% 
% plotRF(hAxis,x,y,xlabelText,ylabelText,titleText,lineStyle)
% 
% produces plots with a consistent look.
% 
% Input:
%   hAxis: use the output of the subplot command.
%   x, y: data to be plotted.
%   xlabelText, ylabelText: x- and y-labels.
%   titleText: plot title.
%   lineStyle: line style, default to be 'b-'.
% 
% copyright (c) Russell Fung 2014
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  if (nargin==6)
    lineStyle = 'b-';
  end
  ymin = min(y);
  ymax = max(y);
  if (abs(ymax-ymin)<0.1)
    ymin = ymin-0.1;
    ymax = ymax+0.1;
  end
  xmin = min(x);
  xmax = max(x);
  if (abs(xmax-xmin)<0.1)
    xmin = xmin-0.1;
    xmax = xmax+0.1;
  end
  plot(x,y,lineStyle,'lineWidth',2);
  set(hAxis,'xlim',[xmin,xmax],'ylim',[ymin,ymax]);
  set(hAxis,'lineWidth',2,'fontSize',15)
  xlabel(xlabelText,'fontSize',15)
  ylabel(ylabelText,'fontSize',15)
  title(titleText,'fontSize',15)
%end

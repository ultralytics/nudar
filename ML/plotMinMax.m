% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

function [h, minVal, maxVal, minX, minY, maxX, maxY] = plotMinMax(xVals,yVals,surfxy,varargin)
h=[];

[maxVal,maxY]   = max(surfxy);
[maxVal,maxX]   = max(maxVal); %max Phi and max y row
maxY            = maxY(maxX); %max x row

[minVal,minY]   = min(surfxy);
[minVal,minX]   = min(minVal); %min Phi and min y row
minY            = minY(minX); %min x row

if nargin==4 && isgraphics(varargin{1})
    ha = varargin{1};
else
    ha = gca;
end  

h(1) = plot(ha, xVals(minX), yVals(minY), '+', 'MarkerSize', 12, 'LineWidth', 1, 'Color', [.8 .1 .1]);
h(2) = text(xVals(minX), yVals(minY), ...
    sprintf(' min=%0.3g',minVal),'Color', [1 0 0], 'HorizontalAlignment','Left','VerticalAlignment','Cap','fontsize',8,...
    'parent',ha);

h(3) = plot(ha, xVals(maxX), yVals(maxY), '+', 'MarkerSize', 12, 'LineWidth', 1, 'Color', [.1 .8 .1]);
h(4) = text(xVals(maxX), yVals(maxY), ...
    sprintf(' max=%0.3g',maxVal),'Color', [0 1 0], 'HorizontalAlignment','Left','VerticalAlignment','Cap','fontsize',8,...
     'parent',ha);
end

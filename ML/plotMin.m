% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

function [h, minVal] = plotMin(x,y,surfxy,varargin)
h=[];
[minVal,i] = min3(surfxy);

if numel(x)~=numel(surfxy)
    x1=x(i(2));
    y1=y(i(1));
else
    x1=x(i(1),1);
    y1=y(1,i(2));
end

if nargin==4 && isgraphics(varargin{1})
    ha = varargin{1};
else
    ha = gca;
end  
color = [.7 .7 .7];

h(1) = plot(ha, x1, y1, '+', 'MarkerSize', 12, 'LineWidth', 1, 'Color', color); hold on
h(2) = text(x1, y1, sprintf(' min=%0.3g',minVal),'Color', color, 'HorizontalAlignment','Left','VerticalAlignment','Cap','fontsize',8);
end

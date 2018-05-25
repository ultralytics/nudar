function [newHandles, bestd, enclosedArea] = plotContour(x,y,z,input,flags,handles)

%FIND 90% CONTOUR DENSITY -------------------------------------------------
[bestd, np] = fcndsearch(z,input.CEValue/100);

%PLOT CONTOUR IN GUI ------------------------------------------------------
[~,newHandles] = contour(handles.GUI.axes1,x,y,log(z),log(bestd)*[1 1],'-','LineWidth',1.5,'Color',[.7 .7 .7]);

%LABEL CONTOUR DENSITY IN GUI ---------------------------------------------
%clabel(cs,h,'fontsize',8,'color','w','rotation',0,'LabelSpacing',5000,'margin',1);

%FIND AREA ENCLOSED BY CONTOUR --------------------------------------------
enclosedArea = np*input.google.maps.pixelspacingkm^2;
end

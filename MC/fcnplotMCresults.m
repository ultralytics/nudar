function [h] = fcnplotMCresults(input, table, flags, handles, p, mlpoint, systematic, d)
newHandles = [];
startclock = clock; %#ok<NASGU>

tf = input.plotTime/input.detectorCollectTime; %time fraction
if ~isempty(d);
    for i = 1:numel(d)
        if d(i).enabledFlag
            n = sum(d(i).epdf.allbackground)*table.mev.de*tf;
            set(handles.detectorText(i),'String', sprintf('  D%.0f, %.0fkm\n  n_Z=%.0f', d(i).number, d(i).range, n),'Color',[0 0 0])
        end
    end
end
set(handles.reactorText,'string',sprintf(' \n  Reactor'),'Color',[0 0 0],'Position',get(handles.reactorText,'Position')+[0 0 0])
set(handles.reactorPoint,'Marker','o','MarkerSize',7,'MarkerEdgeColor',[.8 .8 .8],'MarkerFaceColor','r')
set(handles.detectorPoints,'Marker','o','MarkerSize',7,'MarkerEdgeColor',[.8 .8 .8],'MarkerFaceColor','g')


%PLOT RESULTS CONDITIONAL RESULTS -----------------------------------------
flags.status.EstMenuPlotMarginal = 0;
flags.status.verbose=0;
sca(handles.GUI.axes1)
p0=p;
MLplot

[ha6,hf6] = fig(2,3,1.5);  set(hf6,'Name',input.MCFileName);
popoutsubplot(handles.GUI.axes1, ha6(1));

%PLOT RESULTS MARGINAL RESULTS --------------------------------------------
deleteh(newHandles)
flags.status.EstMenuPlotMarginal = 1;
flags.status.verbose=1;
sca(handles.GUI.axes1)
p=p0;
MLplot

h = newHandles;
h = h(isgraphics(h));
v1 = (h==findobj(h,'type','fig')); 
h = h(~v1);
popoutsubplot(handles.GUI.axes1, ha6(2));
popoutsubplot(findobj(2,'type','axes'), ha6(3));  close(2)
daspect(ha6(1),[1 1 1]); daspect(ha6(2),[1 1 1])

%FIND NUMBER OF POINTS INSIDE ISOVALUE
%mlpoint(:,6) = interp3(1:input.nxy, 1:input.nxy, input.rpVec, p, mlpoint(:,4),mlpoint(:,5),mlpoint(:,3)); %mlpoint = [lat lng rp xycol xyrow esterror(km) esterror(gw)]

lla1 = fcnGoogleMapsXY2LLA(input, flags, mlpoint(:,[4 5]));
lla2 = input.reactor.positionLLA;
mlpoint(:,7) = fcnrange(lla2ecef(lla1),lla2ecef(lla2)); %est error (km)
mlpoint(:,8) = mlpoint(:,3)-input.reactor.power; %est error (gw)

%PLOT ERROR HISTOGRAMS AND 68PERCENTILES ----------------------------------
figure(hf6)
sca(ha6(4))
[n,x]=hist(mlpoint(:,7),1000);
ncdf = cumsum(n);
[~,v1] = unique(ncdf,'first');
cdfy = [0 ncdf(v1)];
cdfx = [1 x(v1)];
yi1 = interp1(cdfy, cdfx, ncdf(1000)*.6827);
yi2 = interp1(cdfy, cdfx, ncdf(1000)*.9545);
[n,x] = hist(mlpoint(:,7),linspace(0,max(mlpoint(:,7)),30));
bar(x,n,1,'EdgeColor',[.9 .9 .9],'FaceColor',[.7 .7 .7]);hold on; axis tight
plot([yi1 yi1],get(gca,'YLim'),'b-','LineWidth',1); plot([yi2 yi2],get(gca,'YLim'),'r-','LineWidth',1)
legend('Histogram',sprintf('68.3%%=%.1fkm',yi1),sprintf('95.5%%=%.1fkm',yi2))
title('Reactor Position Estimate Error Histogram'); xlabel('Position Error (km)'); ylabel('Events')

sca(ha6(5))
mlpoint(:,8) = abs(mlpoint(:,8));
[n,x]=hist(mlpoint(:,8)*1E3,1000);
ncdf = cumsum(n);
[~,v1] = unique(ncdf,'first');
cdfy = [0 ncdf(v1)];
cdfx = [1 x(v1)];
yi1 = interp1(cdfy, cdfx, ncdf(1000)*.6827);
yi2 = interp1(cdfy, cdfx, ncdf(1000)*.9545);
[n,x] = hist(mlpoint(:,8)*1E3,linspace(0,max(mlpoint(:,8)*1E3),30));
bar(x,n,1,'EdgeColor',[.9 .9 .9],'FaceColor',[.7 .7 .7]);hold on; axis tight
plot([yi1 yi1],get(gca,'YLim'),'b-','LineWidth',1); plot([yi2 yi2],get(gca,'YLim'),'r-','LineWidth',1)
legend('Histogram',sprintf('68.3%%=%.1fMWth',yi1),sprintf('95.5%%=%.1fMWth',yi2))
title('Reactor Power Estimate Error Histogram'); xlabel('Reactor Power Error (MWth)'); ylabel('Events')

%PLOT ML4 SYSTEMATIC
if flags.status.ML4
    ni = numel(input.fluxnoise.systematic.mean)+1;
    [ha,hf]=fig(2,ni,.6);  set(hf,'Name',input.MCFileName);
    input.fluxnoise.systematic.labels{ni} = 'UR Power (GWth)';
    a=.7; b=1.3;
    for i = 1:ni
        sca(ha(i))
        if i==ni
            a=input.rp1;
            b=input.rp2;  
        end
        binx = linspace(a,b,50);
        
        [n, x]=hist(systematic.true(:,i),binx); truemu = sum(x.*n)/sum(n);
        h1 = bar(x,n,1); hold on; set(h1,'EdgeColor','none','FaceColor',[.7 .7 .7]); alpha(.5)
        if i == ni
            [n, x]=hist(systematic.est(:,i),binx); estmu = sum(x.*n)/sum(n);
        else
            [n, x]=hist(systematic.est(:,i)-systematic.true(:,i)+1,binx); estmu = sum(x.*n)/sum(n);
        end
        h1 = bar(x,n,1); hold on
        set(h1,'EdgeColor','none','FaceColor','b'); alpha(.5)
        set(gca,'xlim',[a b])
        title(input.fluxnoise.systematic.labels{i})
        legend(sprintf('%.2f%%',100*std(systematic.true(:,i))), sprintf('%.2f%%',100*std(systematic.est(:,i)-systematic.true(:,i))))
       
        sca(ha(i+ni))
        x = systematic.true(:,i);
        y = systematic.est(:,i);
        plot(x,y,'.','markersize',1); axis equal square tight; hold on
        p = polyfitOrthogonal(x,y,1);
        if i<ni; plot([a b], polyval(p,[a b]),'r','LineWidth',1); end
        plot([a b],[a b],'color',[.7 .7 .7],'LineWidth',1)
        title({input.fluxnoise.systematic.labels{i},sprintf('%.3f correlation\n%.3f true mean\n%.3f est mean',corr(x,y),truemu,estmu)})
        set(gca,'xlim',[a b],'ylim',[a b])
        if i==1 ; xlabel('True Systematic'); ylabel('Est. Systematic'); end
        grid on
    end
end
drawnow

end


function input = fcnContextPlotDetectorMeasurements(input, flags, table, d, ~)
xy = d.position;

[~, ~, d] = fcnenergycut(input, flags, table, d);
%d = fcnanglespace(input, table, flags, d, 0);

%PLOT LOCATION IN ECEF
flags.status.mapGoogle=1;
[CdataRotated, input] = fcnGetGoogleMap(input, flags);
lla = fcnGoogleMapsXY2LLA(input, flags, xy(1,1:2));

maps = input.google.maps;
x = reshape(maps.ECEF(:,1),input.nxy,input.nxy);
y = reshape(maps.ECEF(:,2),input.nxy,input.nxy);
z = reshape(maps.ECEF(:,3),input.nxy,input.nxy);
set(figure,'Position',[10 50 1200 800]);
for type=1:2
    subplot(1,2,type)
    surf(x,y,z,'FaceColor','Texture','EdgeColor','none','CData',CdataRotated); hold on
    xlabel('ECEF X (km)'); ylabel('ECEF Y (km)'); zlabel('ECEF Z (km)');
    axis tight equal vis3d; alpha(1); box on; grid off;
    el = 15;
    az = d.positionLLA(2)+90;
    view(az,el)
    camlight headlight
    addBorder(input, maps)
    drawnow
    
    lim = [get(gca,'XLim') get(gca,'YLim') get(gca,'ZLim')]; s = max(abs(lim([1 3 5])-lim([2 4 6])))*.2; %scaling
    ecef2 = lla2ecef(lla + [0 0 s*50]); %elevated for better observability
    
    switch type
        case 1 %plot true unit vectors
            rvecs = d.ztruth.uvec;
            title('True Neutrino Source Vectors')
        case 2 %plot noisy measurement vectors
            rvecs = fcnvec2uvec(d.z.vec);
            title('Measured Neutrino Source Vectors')
    end
    
    %PLOT UNKNOWN REACTOR
    v1 = find(d.ztruth.id==0);
    nv = numel(v1);
    if nv>0
        v = rvecs(v1,:)*s;
        plot3([ecef2(1)*ones(1,nv); v(:,1)'+ecef2(1)], [ecef2(2)*ones(1,nv); v(:,2)'+ecef2(2)], [ecef2(3)*ones(1,nv); v(:,3)'+ecef2(3)],'-r')
    end
    
    %PLOT KNOWN REACTOR CORES
    v1 = find(d.ztruth.id>0 & d.ztruth.id<=input.reactor.IAEAdata.n);
    nv = numel(v1);
    if nv>0
        v = rvecs(v1,:)*s;
        plot3([ecef2(1)*ones(1,nv); v(:,1)'+ecef2(1)], [ecef2(2)*ones(1,nv); v(:,2)'+ecef2(2)], [ecef2(3)*ones(1,nv); v(:,3)'+ecef2(3)],'-y')
    end
    
    %PLOT MANTLE NEUTRINOS
    v1 = find(d.ztruth.id==-1 | d.ztruth.id==-2);
    nv = numel(v1);
    if nv>0
        v = rvecs(v1,:)*s;
        plot3([ecef2(1)*ones(1,nv); v(:,1)'+ecef2(1)], [ecef2(2)*ones(1,nv); v(:,2)'+ecef2(2)], [ecef2(3)*ones(1,nv); v(:,3)'+ecef2(3)],'-b')
    end
   
    %PLOT CRUST NEUTRINOS
    v1 = find(d.ztruth.id==-4 | d.ztruth.id==-5);
    nv = numel(v1);
    if nv>0
        v = rvecs(v1,:)*s;
        plot3([ecef2(1)*ones(1,nv); v(:,1)'+ecef2(1)], [ecef2(2)*ones(1,nv); v(:,2)'+ecef2(2)], [ecef2(3)*ones(1,nv); v(:,3)'+ecef2(3)],'-g')
    end
       
    %PLOT FAST NEUTRONS
    v1 = find(d.ztruth.id==-6);
    nv = numel(v1);
    if nv>0
        v = rvecs(v1,:)*s;
        plot3([ecef2(1)*ones(1,nv); v(:,1)'+ecef2(1)], [ecef2(2)*ones(1,nv); v(:,2)'+ecef2(2)], [ecef2(3)*ones(1,nv); v(:,3)'+ecef2(3)],'-c')
    end
    
    %PLOT ACCIDENTALS
    v1 = find(d.ztruth.id==-7);
    nv = numel(v1);
    if nv>0
        v = rvecs(v1,:)*s;
        plot3([ecef2(1)*ones(1,nv); v(:,1)'+ecef2(1)], [ecef2(2)*ones(1,nv); v(:,2)'+ecef2(2)], [ecef2(3)*ones(1,nv); v(:,3)'+ecef2(3)],'-k')
    end
    
    %PLOT COSMOGENIC
    v1 = find(d.ztruth.id==-8);
    nv = numel(v1);
    if nv>0
        v = rvecs(v1,:)*s;
        plot3([ecef2(1)*ones(1,nv); v(:,1)'+ecef2(1)], [ecef2(2)*ones(1,nv); v(:,2)'+ecef2(2)], [ecef2(3)*ones(1,nv); v(:,3)'+ecef2(3)],'-m')
    end
    drawnow
end



%PLOT MANTLE AND CRUST GLOBES AND Zs --------------------------------------
x = d.est.geouvec*d.DCM_NED2ECEF;
sc = fcnCC2SC(x); el = sc(:,2);
elx = sort(unique(round(el)));
dx = elx(2)-elx(1);
elx180 = -90+dx/2 : dx : 90-dx/2;

% r = table.mantle.uranium.theta - 90;
% r = interp1(r,(1.5:2:90)'); %%%%%%%%%%%%%%%%%%
% del = r(2)-r(1); %dtheta
% extra = r(numel(r))+(del:del:20)'; %to go slightly above horizon;
% elx = [r; extra];

%elx = -90+table.mantle.uranium.theta;
%elx = -90:1:90;
F=griddedInterpolant(elx,1:numel(elx),'nearest'); eli=F(el);

set(figure,'Position',[60 50 1400 900]);
subplot(231)
y1 = sum(d.est.pdf1.mantle,2)*table.mev.de;
elhist1 = accumarray(eli, y1, [numel(elx) 1]);
bar(elx, elhist1, 2,'b','EdgeColor','none'); alpha .7; hold on
y2 = sum(d.est.pdf1.crust,2)*table.mev.de;
elhist2 = accumarray(eli, y2, [numel(elx) 1]);
bar(elx, elhist2, 2,'g','EdgeColor','none'); alpha .7; 
y3 = sum(d.est.pdf1.mantle+d.est.pdf1.crust,2)*table.mev.de;
elhist3 = accumarray(eli, y3, [numel(elx) 1]);
plot(elx, elhist3,'Color',[.7 .7 .7],'LineWidth',1); axis tight
title('Estimator Assumed'); legend('mantle','crust','crust+mantle'); xlabel('Elevation (deg)'); ylabel('Events'); legend boxoff
axis([-90 90 0 max(elhist3)]); set(gca,'XTick',-90:30:90)
fcncontextmenuexpand(gca)

v2 = d.z.candidate & (d.ztruth.id==-1 | d.ztruth.id==-2); %mantle
v1 = d.z.candidate & (d.ztruth.id==-4 | d.ztruth.id==-5); %crust

subplot(232)
sc = fcnCC2SC(d.ztruth.uvec(v1,:)*d.DCM_NED2ECEF);
nc = hist(sc(:,2),elx);
h(1) = bar(elx, nc, 2, 'g', 'EdgeColor', 'none'); alpha .2; hold on
plot(elx, elhist2, 'g','LineWidth',1)
sc = fcnCC2SC(d.ztruth.uvec(v2,:)*d.DCM_NED2ECEF);
nm = hist(sc(:,2),elx);
h(2) = bar(elx, nm, 2, 'b', 'EdgeColor', 'none'); alpha .2; hold on
plot(elx, elhist1, 'b','LineWidth',1)
h(3) = plot(elx, nc+nm, 'Color',[.7 .7 .7],'LineWidth',1);
title('True Events'); xlabel('Elevation (deg)'); ylabel('Events'); 
legend(h,sprintf('crust %.1f%%',input.fluxnoise.systematic.rand(3)*100), ...
    sprintf('mantle %.1f%%',input.fluxnoise.systematic.rand(2)*100), ...
    sprintf('crust+mantle %.1f%%',input.fluxnoise.systematic.rand(7)*100)); legend boxoff
axis([-90 90 0 max(elhist3)]); set(gca,'XTick',-90:30:90)
fcncontextmenuexpand(gca)

subplot(233)
cla
sc = fcnCC2SC(fcnvec2uvec(d.z.vec(v1,:))*d.DCM_NED2ECEF);
nc = hist(sc(:,2),elx180);
h(1) = bar(elx180, nc, 1, 'g', 'EdgeColor', 'none'); alpha .2; hold on
plot(elx, elhist2, 'g','LineWidth',1)
sc = fcnCC2SC(fcnvec2uvec(d.z.vec(v2,:))*d.DCM_NED2ECEF);
nm = hist(sc(:,2),elx180);
h(2) = bar(elx180, nm, 1, 'b', 'EdgeColor', 'none'); alpha .2; hold on
plot(elx, elhist1, 'b','LineWidth',1)
title('Measured Events'); xlabel('Elevation (deg)'); ylabel('Events'); 
legend(h,sprintf('crust %.1f%%',input.fluxnoise.systematic.rand(3)*100), ...
    sprintf('mantle %.1f%%',input.fluxnoise.systematic.rand(2)*100), ...
    sprintf('crust+mantle %.1f%%',input.fluxnoise.systematic.rand(7)*100)); legend boxoff
axis([-90 90 0 max(elhist2)]); set(gca,'XTick',-90:30:90)
fcncontextmenuexpand(gca)

subplot(234)
scatter3(x(:,1), x(:,2), x(:,3), 30, y1,'filled'); box on; axis image vis3d; grid off; hold on
caxis([0 max(y1)]); xlabel('x'); ylabel('y'); zlabel('z'); set(gca,'ydir','reverse','zdir','reverse')
a = fcnvec2uvec(d.z.vec(v2,:))*d(1).DCM_NED2ECEF * 1.2;
b = fcnvec2uvec(d.ztruth.uvec(v2,:))*d(1).DCM_NED2ECEF * 1.4;
plot3(a(:,1), a(:,2),a(:,3),'.','MarkerSize',5,'color',[.7 .7 .7])
plot3(b(:,1), b(:,2),b(:,3),'.','MarkerSize',5,'color',[0 0 1])
title('Mantle')
fcncontextmenuexpand(gca)

subplot(235)
scatter3(x(:,1), x(:,2), x(:,3), 30, y2,'filled'); box on; axis image vis3d; grid off; hold on
caxis([0 max(y2)]); xlabel('x'); ylabel('y'); zlabel('z'); set(gca,'ydir','reverse','zdir','reverse')
c = fcnvec2uvec(d.z.vec(v1,:))*d(1).DCM_NED2ECEF * 1.2;
e = fcnvec2uvec(d.ztruth.uvec(v1,:))*d(1).DCM_NED2ECEF * 1.4;
plot3(c(:,1), c(:,2),c(:,3),'.','MarkerSize',5,'color',[.7 .7 .7])
plot3(e(:,1), e(:,2),e(:,3),'.','MarkerSize',5,'color',[0 1 0])
title('Crust')
fcncontextmenuexpand(gca)

subplot(236)
scatter3(x(:,1), x(:,2), x(:,3), 30, y3,'filled'); box on; axis image vis3d; grid off; hold on
caxis([0 max(y3)]); xlabel('x'); ylabel('y'); zlabel('z'); set(gca,'ydir','reverse','zdir','reverse')
plot3(a(:,1), a(:,2),a(:,3),'.','MarkerSize',5,'color',[.7 .7 .7])
plot3(b(:,1), b(:,2),b(:,3),'.','MarkerSize',5,'color',[0 0 1])
plot3(c(:,1), c(:,2),c(:,3),'.','MarkerSize',5,'color',[.7 .7 .7])
plot3(e(:,1), e(:,2),e(:,3),'.','MarkerSize',5,'color',[0 1 0])
title('All Geo')
fcncontextmenuexpand(gca)





end


function addBorder(input, maps)
np = 100; %number of points;
ex = maps.extent;
latv = linspace(ex(1),ex(2),np)';
lngv = linspace(ex(3),ex(4),np)';
latvr = linspace(ex(2),ex(1),np)';
lngvr = linspace(ex(4),ex(3),np)';
ov = ones(np,1);

lats = [latv;       ex(2)*ov;   latvr;      ex(1)*ov  ];
lngs = [ex(3)*ov;   lngv;       ex(4)*ov;   lngvr     ];
zi = etopo1(lats,lngs,input.ETOPO);

ecef = lla2ecef([lats lngs zi]);
plot3(ecef(:,1),ecef(:,2),ecef(:,3),'-','Color',[.7 .7 .7])
end



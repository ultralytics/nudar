function [input, d, h] = fcnUpdateGoogleMap(input, d, h, flags, table)
%fcnUpdateGoogleMap(input, handles)

if input.google.maps.zoom == 1 %center map at max zoomOut
   input.google.maps.lat = 0;
   input.google.maps.lng = 0;
end

%SET X AND Y MATRICES FOR PCOLOR ------------------------------------------
XLim        = [0 input.nxy];
xyVec       = linspace(XLim(1),XLim(2),input.nxy);
X           = ones(input.nxy,1)*xyVec; %x values on square surface
Y           = X';

%GET MAP ------------------------------------------------------------------
[CdataRotated, input] = fcnGetGoogleMap(input, flags);
gm = input.google.maps;

deleteh(h.map);
xy=linspace(0,input.nxy,2);
if flags.status.mapGoogle %plot Google Map
    h.map=surf(xy,xy,zeros(2)+10,'FaceColor','Texture','EdgeColor','none','CData',CdataRotated);
    alpha(h.map,0.5);
end

%update ECEF data for each point on map
latVec2 = interp1((1:640)',gm.latVec',gm.rescale6402nxy');
lngVec2 = interp1((1:640)',gm.lngVec',gm.rescale6402nxy');

input.google.maps.extentML = [latVec2(1) latVec2(input.nxy) lngVec2(1) lngVec2(input.nxy)];

extent = input.google.maps.extent;
spacing = ceil(max(extent([2 4])-extent([1 3]))/22);
spacing = ceil(max(extent([2 4])-extent([1 3]))/10);


%SET LATS -----------------------------------------------------------------
lats = ceil(extent(1)):spacing:floor(extent(2));
LLA = fcnLLA2GoogleMapsXY(input,lats'*[1 0 0]);
XTick = LLA(:,1)';

ni = numel(XTick);
XTickLabel = cell(ni,1);
for i = 1:ni
    XTickLabel{i} = num2str(lats(i));
end

%SET LNGS -----------------------------------------------------------------
lngs = ceil(extent(3)):spacing:floor(extent(4));
LLA = fcnLLA2GoogleMapsXY(input,lngs'*[0 1 0]);
YTick = LLA(:,2)';

ni = numel(YTick);
YTickLabel = cell(ni,1);
for i = 1:ni
    YTickLabel{i} = num2str(lngs(i));
end

l=get(h.GUI.axes1,'XLim'); l = l(2);
gain = l/input.nxy;
set(h.GUI.axes1, 'XTick', XTick*gain, 'XTickLabel', XTickLabel, 'YTick', YTick*gain, 'YTickLabel', YTickLabel);

%update map label
set(h.GUI.textGoogleMaps,'string',sprintf('Lat=%.2f, Long=%.2f, Zoom=%.0fX',gm.lat,gm.lng,gm.zoom))
%format_ticks(gca,'{^o}','{^o}');

[LAT,LNG] = meshgrid(latVec2, lngVec2);
LATm = reshape(LAT,input.nxy^2,1); %lat matrix
LNGm = reshape(LNG,input.nxy^2,1); %lng matrix
[ETOPO, input.ETOPO] = etopo1(LATm,LNGm,input.ETOPO); %get elevations for lat lng points from my etopo1 (ice grid) database

LLA = [LATm LNGm ETOPO];
ECEF = lla2ecef(LLA);

input.google.maps.LLA = LLA;
input.google.maps.ECEF = ECEF;

%GET PIXEL SPACING IN KM AND DEG FOR CENTER PIXEL
i = round(input.nxy/2);
ecef = lla2ecef([latVec2([i i i i+1]), lngVec2([i i+1 i i]), [0 0 0 0]']);
input.google.maps.pixelspacingkm = norm(ecef(2,:)-ecef(1,:))/2 + norm(ecef(4,:)-ecef(3,:))/2;
input.google.maps.pixelspacingdeg = mean(abs([diff(latVec2(i:i+1)) diff(lngVec2(i:i+1))]));

%Update detectors
input.google.maps.currentrmax = 0;
d = fcncleardtables(d, input);

%PLOT OPTIONAL MAP OVERLAYS -----------------------------------------------
ETOPOm = reshape(ETOPO,input.nxy,input.nxy); %used in contour
if flags.status.mapElevation
    z = ETOPOm;
elseif flags.status.mapIAEABackground
    kr = input.reactor.IAEAdata.unique; %known reactors
    events = zeros(size(ECEF,1),1);
    
    s=fcnspec1s(table.mev.e, table.mev.r, [], 0, 1, 1, table.mev.pdf0, table.mev.fs);
    s=fcnspec1s(4:.01:4.05, table.mev.r, [], 1, 1, 1);
    for i = 1:kr.n
        r = fcnrange(kr.ecef(i,:), ECEF);
        ri = fcnindex1(table.mev.r, r);
        events = events + s.n(ri)*input.reactor.IAEAdata.unique.GWth(i);
    end
    events = log10(events * (.8)); %for time and detector size, and .8 neutron capture efficiency
    sevents = sort(events,1,'descend');
    ceiling = sevents(round(numel(events)*.05));
    %events = min(events,ceiling);
    z = reshape(events,input.nxy,input.nxy);
elseif flags.status.mapCrustBackground
    z = zeros(input.nxy,input.nxy);
elseif flags.status.mapCombinedBackground
    z = zeros(input.nxy,input.nxy);
end

deleteh(h.mapOverlay); h.mapOverlay=[];
if flags.status.mapElevation || flags.status.mapIAEABackground || flags.status.mapCrustBackground ||  flags.status.mapCombinedBackground
    h.mapOverlay = pcolor(X,Y,z); shading flat;
    set(h.mapOverlay,'Zdata',ones(input.nxy,input.nxy)*10);
    [minz, maxz] = fcnminmax(z);
    alpha(.7)
    
    if flags.status.mapIAEABackground && minz~=maxz
        maxz=ceiling;
        [cs,ch] = contour(h.GUI.axes1,z,round(linspace(minz,maxz,5)),'w-','LineWidth',1);
        h.mapOverlay = [h.mapOverlay ch];
        clabel(cs,ch,'fontsize',12,'color','w','rotation',0,'LabelSpacing',250);
    end
    
    caxis(h.GUI.axes1, [minz maxz] )
end

%PLOT OPTIONAL CONTOURS ---------------------------------------------------
deleteh(h.mapContour); h.mapContour=[];
if flags.status.mapContours
    l=get(h.GUI.axes1,'XLim'); l = l(2);
    x = linspace(0,l,input.nxy);
    [~, h.mapContour] = contour(x,x,ETOPOm, [0 0], 'k-','LineWidth',1);
end

%PLOT IAEA REACTOR LABELS -------------------------------------------------
deleteh(h.IAEAPoints);  h.IAEAPoints=[];
deleteh(h.IAEAText);    h.IAEAText=[];
if flags.status.mapIAEAreactors
    A = input.reactor.IAEAdata.unique.lla;
    extent = gm.extent;
    v1 = find(A(:,1)>extent(1) & A(:,1)<extent(2) & A(:,2)>extent(3) & A(:,2)<extent(4));
    nv1 = numel(v1);
    if nv1>0
        xy = fcnLLA2GoogleMapsXY(input,A(v1,1:3));
        o = strcmpi(input.reactor.IAEAdata.unique.status(v1),'operational');
        
        if any(o);   h.IAEAPoints = plot3(xy(o,1),xy(o,2),-ones(sum(o),1),'.','Marker','o','MarkerSize',5,'MarkerEdgeColor',[.8 .8 .8],'MarkerFaceColor',[1 1 0]); end
        if any(~o);  h.IAEAPoints(end+1) = plot3(xy(~o,1),xy(~o,2),-ones(sum(~o),1),'.','Marker','o','MarkerSize',5,'MarkerEdgeColor',[.8 .8 .8],'MarkerFaceColor',[0 0 1]); end
        
        if input.google.maps.zoom>4 %if zoomed in enough, plot labels
            B = input.reactor.IAEAdata.unique.GWth;
            C = input.reactor.IAEAdata.unique.sitename;
            
            stringArray = cell(nv1,1);
            for n = 1:nv1
                in = v1(n);
                stringArray{n} = sprintf('  %s (%1.1fGWt)',C{in},B(in));
            end
            
            h.IAEAText = text(xy(:,1),xy(:,2),stringArray);
            set(h.IAEAText,'HorizontalAlignment','Left','fontsize',10,'Color',[.5 .5 .5])
        end
        
        %ADD CONTEXT MENU -------------------------------------------------
        hcmenu = uicontextmenu;
        uimenu(hcmenu, 'Label', 'View Details', 'Callback', ['fcnContextPlotIAEAreactorDetails(input, flags, handles, get(handles.GUI.axes1,''CurrentPoint''))']); %item1
        set([h.IAEAText; h.IAEAPoints(:)],'uicontextmenu',hcmenu)
    end
end


end



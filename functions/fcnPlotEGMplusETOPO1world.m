% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

function [] = fcnPlotEGMplusETOPO1world(input, flags)
flags.status.SeaMenuDetectorFloat=1;
flags.status.SeaMenuEGM96=1;
flags.status.SeaMenuWGS84=0;
nr = 500;
nc = 1000;
r = linspace(90,-90,nr);
c = linspace(-180,180,nc);
[rm,cm] = meshgrid(r,c);
rmv = reshape(rm,nr*nc,1);
cmv = reshape(cm,nr*nc,1);
zmv = fcnGetAltitude(input, flags, rmv, cmv);
zm = reshape(zmv,nc,nr);

if numel(input.EGM.lonbp)>2000
    egmName = 'EGM2008';
else
    egmName = 'EGM96';
end

fig(1,1,'19x38cm')
pch = pcolor(cm,rm,zm); hold on; shading flat; ch=colorbar('East'); axis equal tight
xlabel('Longitude (deg)'); ylabel('Latitude (deg)'); title({['Height Above WGS84 Ellipsoid (Meters) using NOAA ETOPO1 and NGA ' egmName ' Data'],'Plate Carr?e Projection'})
set(gca,'YTick',-90:30:90,'XTick',-180:30:180);
set(ch,'YColor','w')

%PLOT LAND CONTOUR FROM ETOPO1 --------------------------------------------
a=load('coast');  plot(a.long,a.lat,'w-','linewidth',1)
drawnow

%GENERATE GOOGLE EARTH OVERLAY --------------------------------------------
extent = [-90 90 -180 180];
picfname = ['Combined ' egmName ' and ETOPO1 Overlay.png'];
fcnGenerateKMLoverlayPNG(input, picfname, rm, cm, zm, extent)
fcnGenerateKMLoverlay(input,['Combined ' egmName ' and ETOPO1 Overlay.kml'],picfname,['Combined ' egmName ' and ETOPO1 Overlay'],extent)

%ADD GOOGLE EARTH OVERLAY CONTEXT MENU %-----------------------------------
hcmenu = uicontextmenu;
hcb1 = ['winopen([input.directory ''/GEfiles/KML/'' [''Combined ' egmName ' and ETOPO1 Overlay.kml'']])'];
uimenu(hcmenu, 'Label', 'View in Google Earth', 'Callback', hcb1); %item1
set(pch,'uicontextmenu',hcmenu)
end


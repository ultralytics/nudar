% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

function [] = fcnGenerateKMLoverlayPNG(input, picfname, lats, lngs, z, extent)
%This function creates a PNG suitable for use as a KML overlay. The PNG is
%Plate Carree projected (cylindrical).
fprintf('Generating ''%s'' in folder ''%s''...',picfname,[input.directory filesep 'GEfiles' filesep 'KML' filesep]); tstart=clock;


z = z-min(min(z));
z = z/max(max(z));
dmax = max(extent(4)-extent(3),extent(2)-extent(1)); %deg
if dmax>350 %must be full earth
    dx = dmax/2880/2; %space 2000 pixels along the largest dimension
else
    dx = dmax/1000; %space 1000 pixels along the largest dimension
end

xiv = extent(2):-dx:extent(1); %lat order is reversed because row order is reversed with imwrite
yiv = extent(3):dx:extent(4);

[xi,yi] = meshgrid(xiv, yiv);
[tr, tc] = size(lats);
if  tr==1 || tc==1 %need to meshgrid these 1d vectors
    [lats, lngs] = meshgrid(lats,lngs);
    z = z';
end

zi = interp2(lats,lngs,z,xi,yi,'linear');
imwrite(uint8(zi'*63),parula(256),[input.directory filesep 'GEfiles' filesep 'KML' filesep picfname])

fprintf('   Done. (%.1fs)\n',etime(clock,tstart))
end


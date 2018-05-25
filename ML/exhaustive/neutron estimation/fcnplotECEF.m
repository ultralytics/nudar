function input = fcnplotECEF(input, flags, table, d)
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

surf(x,y,z,'FaceColor','Texture','EdgeColor','none','CData',CdataRotated); hold on
xyzlabel('ECEF X (km)','ECEF Y (km)','ECEF Z (km)');
axis tight equal vis3d; box on; grid off;
el = 15;
az = d.positionLLA(2)+90;
view(az,el)
camlight headlight
addBorder(input, maps)
alpha(.7);


ns=size(d.z.v0s,1);  p1 = repmat(d.positionECEF,[ns 1]);  p2 = d.z.v0s/1E3*50 + p1;
plot3([p1(:,1) p2(:,1)]',[p1(:,2) p2(:,2)]',[p1(:,3) p2(:,3)]','b.-','DisplayName',sprintf('%g Signal',ns));

nb=size(d.z.v0b,1);  p1 = repmat(d.positionECEF,[nb 1]);  p2 = d.z.v0b/1E3*50 + p1;
plot3([p1(:,1) p2(:,1)]',[p1(:,2) p2(:,2)]',[p1(:,3) p2(:,3)]','r.-','DisplayName',sprintf('%g Background',nb));

fcnlegend(gca,1,'unique')
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



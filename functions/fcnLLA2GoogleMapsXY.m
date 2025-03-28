% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

function xy = fcnLLA2GoogleMapsXY(input,LLA)
lat = LLA(:,1);
lng = LLA(:,2);

extent = input.google.maps.extent;

%GOOGLE MAPS Y POINT
totalPixelCount = round(input.pixelsPerDeg*360);
y640 = (lng - extent(3)) * input.pixelsPerDeg;

%GOOGLE MAPS X POINT
absLatPixelAtMapOrigin = 1/2*log((1+sind(extent(1)))  / (1-sind(extent(1))))    / pi * totalPixelCount/2; %absolute lat pixel above equator
absLatPixelAtLatPoint  = 1/2*log((1+sind(lat))./(1-sind(lat)))./ pi * totalPixelCount/2; %absolute lat pixel above equator
x640 = absLatPixelAtLatPoint-absLatPixelAtMapOrigin;

x = (x640)*input.nxy/639;
y = (y640)*input.nxy/639;

xy = [x y];
end


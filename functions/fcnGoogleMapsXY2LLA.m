% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

function LLA = fcnGoogleMapsXY2LLA(input, flags, xy)
r2d = 180/pi;
xy640 = xy*(639/input.nxy);
extent = input.google.maps.extent;

localLatPixel = xy640(:,1);
localLngPixel = xy640(:,2);

%LONGITUDE
totalPixelCount = round(input.pixelsPerDeg*360);
lng = extent(3) + localLngPixel/input.pixelsPerDeg;

%LATITUDE
%maxLat = 2*atan(exp(pi))-pi/2; %rad, deg = 85.05deg
absLatPixel = 1/2*log((1+sind(extent(1)))/(1-sind(extent(1)))) / pi * totalPixelCount/2; %absolute lat pixel above equator
absLatRadians = (absLatPixel+localLatPixel)/(totalPixelCount/2) * pi;
lat = (2*atan(exp(absLatRadians))-pi/2) * r2d;

%ALTITUDE
%altitude = fcnGoogleElevation(lat,lng); %from google's servers
altitude = fcnGetAltitude(input, flags, lat, lng);

%LLA
LLA = [lat lng altitude];
end


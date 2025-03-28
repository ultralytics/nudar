% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

function [zi, input] = fcnGetGoogleMap(input, flags)
gm = input.google.maps;
if isfield(gm, 'Cdata')
    if ~isempty(gm.Cdata)
        if gm.Cdataloc == [gm.lat, gm.lng, gm.zoom];
            zi = gm.Cdata;
            return
        end
    end
end
zi = [];

pixelVec = linspace(-319.5,319.5,640);

%LONGITUDE
%check for wrapping
if abs(gm.lng)>180
    gm.lng = (gm.lng-360*sign(gm.lng));
end
input.pixelsPerDeg = (256*2^gm.zoom) / (360*cos(gm.lat*0*d2r));
totalPixelCount = round(input.pixelsPerDeg*360);
lngVec = gm.lng + pixelVec/input.pixelsPerDeg;

%LATITUDE
%maxLat = 2*atan(exp(pi))-pi/2; %rad, deg = 85.05deg
latPixel = 1/2*log((1+sind(gm.lat))/(1-sind(gm.lat))) / pi * totalPixelCount/2;
latPixelVec = (latPixel+pixelVec)/(totalPixelCount/2) * pi;
latVec = (2*atan(exp(latPixelVec))-pi/2) * r2d;

%IMAGE LAT LONG EXTENTS
gm.extent = [latVec([1 640]) lngVec([1 640])]; %centerpixel

%BUILD URL
if flags.status.mapGoogle
    tic

    scale = 1;
    address=['http://maps.google.com/maps/api/staticmap?center=' sprintf('%.6f',gm.lat) ',' sprintf('%.6f',gm.lng) '&zoom=' sprintf('%.0f',gm.zoom) '&size=640x640&scale=' sprintf('%.0f',scale) '&maptype=' gm.mapType];
    
    latlongs = getIAEAMarkers(gm, input);
    if numel(latlongs>0)
        address = [address '&markers=color:yellow|label:R|size:mid|' latlongs];
    end
    
    [latlongs, nA]  = getDetectorMarkers(input);
    if nA
        address = [address '&markers=color:green|label:D|size:mid|' latlongs];
    end
    
    [latlongs, nA]  = getReactorMarkers(input, flags);
    if nA
        address = [address '&markers=color:red|label:R|size:mid|' latlongs];
    end

    warning('off', 'all')
    try
        [I, map]=imread(address);
    catch
        I=ones(640*scale,640*scale,1);
        map = parula;
    end
    warning('on', 'all')
    I = imrotate(I,-90);
    
    zi=ind2rgb(I,map);
    zi = (1-zi)*.3 + zi; %whiten
    zi = uint8(zi*255);
    
    fprintf('Google Static Maps API URL retrieved (%.2fs): %s\n',toc,address)
end
gm.Cdata = zi;
gm.Cdataloc = [gm.lat, gm.lng, gm.zoom];

gm.latVec = latVec;
gm.lngVec = lngVec;

input.google.maps = gm;

end

% function pix = getPixelsPerLonDegree(zoom,lat)
% pix = (256*2^zoom) / (360*cosd(lat));
% end


function [str, nA]  = getReactorMarkers(input, flags)
nA = flags.reactorPlaced;
str='';
if nA>0
    A = input.reactor.positionLLA(:,1:2);
    str = sprintf('|%.5f,%.5f',A');
end
end

function [str, nA]  = getDetectorMarkers(input)
nA = input.dValid.count;
str='';
if nA>0
    A = input.dValid.LLA(:,1:2);
    str = sprintf('|%.5f,%.5f',A');
end
end

function [str, v1]  = getIAEAMarkers(gm, input)
A = input.reactor.IAEAdata.unique.lla(:,1:2);
extent = gm.extent;
v1 = find(A(:,1)>extent(1) & A(:,1)<extent(2) & A(:,2)>extent(3) & A(:,2)<extent(4));  n=numel(v1);
str='';
if n>0
    v1 = v1(1:min(n,100)); %limit to 150 markers
    str = sprintf('|%.4f,%.4f',A(v1,:)');
end
end
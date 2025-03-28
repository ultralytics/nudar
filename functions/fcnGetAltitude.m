% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

function [z, z1] = fcnGetAltitude(input, flags, lat, lng)
%z = altitude in meters using custom sink/float/depth stuff
%z1 = ETOPO1 altitude over WGS84
%z2 = sea level altitude at this location using EGM or WGS84

z = etopo1(lat,lng,input.ETOPO); z1=z;
if flags.status.SeaMenuDetectorFloat || flags.status.SeaMenuDetectorSinkCustom
    if flags.status.SeaMenuDetectorSinkCustom
        depth = input.detectorSinkDepth; %depth below sea level surface
    else
        depth = 0;
    end
    
    v1 = find(z<100); %max egm alt is about 90m
    nv1 = numel(v1);
    if nv1>0
        if flags.status.SeaMenuEGM96 || flags.status.SeaMenuEGM2008
            z2 = egm1(lat(v1),lng(v1),input.EGM); %altitude at sea level
        elseif flags.status.SeaMenuWGS84
            z2 = zeros(nv1,1);
        end
        
        z(v1) = max(z(v1),z2 + depth); %depth is negative, i.e. -1500 is 1500m below sea level
    end
else

end

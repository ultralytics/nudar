% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

function [] = fcnContextPlotIAEAreactorDetails(input, flags, h, xy)
%GET ECEF
lla = fcnGoogleMapsXY2LLA(input, flags, xy(1,1:2));
ecef = lla2ecef(lla);

%GET CLOSEST REACTOR
st = input.reactor.IAEAdata; %struct
dx = st.unique.ecef - ones(st.unique.n,1)*ecef;
r = sqrt(dx(:,1).^2 + dx(:,2).^2 + dx(:,3).^2);
[~,usID] = min(r);
cIDs = find(st.ecef(:,1)==st.unique.ecef(usID,1));

%WRITE DETAILS TO WORKSPACE
nc = numel(cIDs);
clc
fprintf('%s, %s\n',st.unique.sitename{usID}, st.country{cIDs(1)})
fprintf('[%5.2f %5.2f %5.2f] (Latitude Longitude Altitude(m))\n',st.unique.lla(usID,:))
fprintf('[%5.2f %5.2f %5.2f] (km ECEF XYZ)\n',st.unique.ecef(usID,:))
fprintf('\n%.0f cores, %4.2f GW Combined Thermal Output:\n',nc,st.unique.GWth(usID))
for c=1:nc
    fprintf('Core %.0f: %s (%s), %4.2f GWth\n',c,st.sitename{cIDs(c)},st.status{cIDs(c)},st.GWth(cIDs(c)))
end
fprintf('\n')

%WRITE WEBPAGE
lla = st.unique.lla(usID,:);
str = [st.unique.sitename{usID} ' nuclear power plant in ' st.country{cIDs(1)}];
address = ['http://www.google.com/search?q='  str ];%'&btnI']; %add btnI if you're "feeling lucky" in google

%OPEN WEBPAGE
web(address,'-browser');

%SHOW IN GE
handle = actxserver ('googleearth.ApplicationGE');%  Create a COM server running Google Earth
pause(1)
alt = 0;
altMode = 2;
range = 2000;
tilt = 30;
heading = 2;
speed = 1;
handle.SetCameraParams(lla(1),lla(2),alt,altMode,range,tilt,heading,speed);
pause(1.5)
delete(handle)

color = '#FF00FFFF'; %yellow
fcnGenerateKMLplacemark(input, lla, [st.unique.sitename{usID} ' REACTOR'], 'singlePlacemark.kml', color)
end

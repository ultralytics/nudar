% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

input.google.maps.lat = 36;
input.google.maps.lng = 9;

input.reactor.position = input.nxy/2*[1 1];%mean([1 input.nxy])*[1 1];
input.reactor.positionLLA = fcnGoogleMapsXY2LLA(input,flags, input.reactor.position);
input.reactor.positionECEF = lla2ecef(input.reactor.positionLLA);

d2r = pi/180;

DCM_ECEF2NED = fcnLLA2DCM_ECEF2NED(input.reactor.positionLLA*d2r);
DCM_NED2ECEF = DCM_ECEF2NED';


r = 10; %km
az = [60 180 -60]*d2r;

for i = 1:3
    d(i).positionECEF = input.reactor.positionECEF + [r*cos(az(i)) r*sin(az(i)) 0]*DCM_NED2ECEF';
    d(i).positionLLA = ecef2lla(d(i).positionECEF);
end



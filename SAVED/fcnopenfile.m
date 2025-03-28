% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

function [d, input, handles, flags] = fcnopenfile(filename, table, stable, oldinput)
cla
new = load(filename);

input = oldinput;
input.google.maps.zoom = new.input.google.maps.zoom;
input.google.maps.lat = new.input.google.maps.lat;
input.google.maps.lng = new.input.google.maps.lng;

input.scenario = filename( max(strfind(filename,filesep))+1 : max(strfind(filename,'.'))-1);

flags = evalin('base','flags'); %flags = new.flags;
flags.reactorPlaced=0;

[input, d] = fcnCreateValidDetectorList(input, []);
input.dCount = 0;
input = fcnupdatefluxnoise(input, table, d, flags);

evalin('base','inithandles');
handles = evalin('base','handles');
[input, d, handles] = fcnUpdateGoogleMap(input, d, handles, flags, table);

lla = new.input.reactor.positionLLA;
create1Detector %reactor

evalin('base','reset(RandStream.getGlobalStream)');
for i=1:new.input.dCount
    lla = new.d(i).positionLLA;
    create1Detector
end

end


% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

function fcnGenerateKMLcylinders(input, flags)
kmlStr_IAEA='';
kmlStr_Reactor='';
kmlStr_Detectors='';

radius = min(8000,(1000*input.google.maps.pixelspacingkm*input.nxy)*.02) / .85;
%radius = min(8000,(1000*input.google.maps.pixelspacingkm*input.nxy)*.05) / 1;

%OPERATIONAL REACTORS (yellow)
operational = strcmpi(input.reactor.IAEAdata.unique.status,'operational');
A  = input.reactor.IAEAdata.unique.lla(operational,1:2);
GWth = input.reactor.IAEAdata.unique.GWth(operational);
for k=1:numel(A(:,1))
    S = ge_cylinder(A(k,2),A(k,1),radius,5e5*(GWth(k)/10),...
                                'polyColor','FFFFF000',...
                                'lineColor','FFFFF000',...
                                'lineWidth',0,...
                                'divisions',6);
    kmlStr_IAEA = [kmlStr_IAEA S];
end

%UNDER CONSTRUCTION REACTORS (blue)
A  = input.reactor.IAEAdata.unique.lla(~operational,1:2);
GWth = input.reactor.IAEAdata.unique.GWth(~operational);
for k=1:numel(A(:,1))
    S = ge_cylinder(A(k,2),A(k,1),radius,5e5*(GWth(k)/10),...
                                'polyColor','FF0000FF',...
                                'lineColor','FF0000FF',...
                                'lineWidth',0,...
                                'divisions',6);
    kmlStr_IAEA = [kmlStr_IAEA S];
end

%UNKNOWN REACTOR
if flags.reactorPlaced
    B = input.reactor.positionLLA;
    for k=1
        S = ge_cylinder(B(k,2),B(k,1),radius,5e5*(input.reactor.power/10),...
            'polyColor','FFFF0000',...
            'lineColor','FFFF0000',...
            'lineWidth',0,...
            'divisions',6);
        kmlStr_Reactor = [kmlStr_Reactor S];
    end
end

%DETECTORS (green)
if input.dCount>0
    for k=1:input.dValid.count
        C = input.dValid.LLA(k,1:3);
        S = ge_cylinder(C(2),C(1),radius,5e5,...
             'polyColor','FF00FF00',...
             'lineColor','FF00FF00',...            
            'lineWidth',0,...
            'divisions',6);
        kmlStr_Detectors = [kmlStr_Detectors S];
    end
end
% blue = FF0000FF


kmlStr_all = [ge_folder('IAEA Known Reactor Locations',kmlStr_IAEA),ge_folder('Unknown Reactor Location',kmlStr_Reactor),ge_folder('Neutrino Detectors',kmlStr_Detectors)];
%kmlStr_all = [ge_folder('Northern hemisphere',NorthStr),ge_folder('Southern hemisphere',SouthStr)]; % you can put folders into subfolders!
fname =  [input.directory filesep 'GEfiles' filesep 'KML' filesep 'cylinders.kml'];
ge_output(fname,kmlStr_all,'name','Reactors and Detectors')
end



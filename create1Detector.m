% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

if ~exist('lla','var')
    lla=fcnGoogleMapsXY2LLA(input, flags, [xi yi]);
else
    xy=fcnLLA2GoogleMapsXY(input, lla);  xi=xy(1);  yi=xy(2);
end
ecef=lla2ecef(lla);

if flags.reactorPlaced %place a new detector
    input.dCount = input.dCount+1;
    m = input.dCount;
    input.dEnabled(m)=1;
    
    handles.detectorPoints(m) = plot(xi,yi,'Marker','o','MarkerSize',5,'MarkerEdgeColor',[.8 .8 .8],'MarkerFaceColor','g');
    handles.detectorText(m) = text(xi,yi,'  Building Detector...','HorizontalAlignment','Left','FontSize',10,'FontWeight','normal'); %initialize these text objects so they can be modified later
    
    %ADD CONTEXT MENU -------------------------------------------------
    hcmenu = uicontextmenu;
    mstr = num2str(m);
    uimenu(hcmenu,  'Label', 'View Details', 'Callback', ['[table] = fcnContextPlotDetectorDetails(input, flags, table, handles, d(' mstr '));']);
    uimenu(hcmenu,  'Label', 'View Measurements', 'Callback', ['[input] = fcnContextPlotDetectorMeasurements(input, flags, table, d(' mstr '), get(handles.GUI.axes1,''CurrentPoint''));']);
    uimenu(hcmenu,  'Label', 'View Angle Space', 'Callback', ['d1=fcnContextPlotAngleSpace(input, flags, table, d(' mstr '), get(handles.GUI.axes1,''CurrentPoint''));']);
    uimenu(hcmenu,  'Label', 'View Energy Space', 'Callback', ['fcnContextPlotEnergySpace(input, flags, table, d(' mstr '), get(handles.GUI.axes1,''CurrentPoint''));']);
    uimenu(hcmenu,  'Label', 'View Mean Event Sources', 'Callback', ['fcnContextPlotDetectorEventSources(input, flags, table, d(' mstr '), get(handles.GUI.axes1,''CurrentPoint''));']);
    uimenu(hcmenu,  'Label', 'View Crust2.0 Breakdown', 'Callback', ['fcnContextPlotDetectorCrustTiles(input, table, flags, d(' mstr '), get(handles.GUI.axes1,''CurrentPoint''));']); %item1
    set([handles.detectorPoints(m); handles.detectorText(m)],'uicontextmenu',hcmenu)
    drawnow
    
    d(m).enabledFlag = true;
    d(m).crustBrokenDownFlag = false;
    d(m).position = [xi yi];
    d(m).positionLLA = lla;
    d(m).positionECEF = ecef;
    d(m).DCM_NED2ECEF = fcnLLA2DCM_NED2ECEF(lla*pi/180);
    
    [~, d(m).waterdepth] = fcnGetAltitude(input, flags, lla(1), lla(2));
    d(m).waterdepth = min(d(m).waterdepth, 0);
    if flags.status.SeaMenuEGM96 || flags.status.SeaMenuEGM2008
        d(m).sealevelaltitude = egm1(lla(1),lla(2),input.EGM); %altitude at sea level
    elseif flags.status.SeaMenuWGS84
        d(m).sealevelaltitude = 0;
    end
    d(m).detectordepth = min(d(m).positionLLA(3) - d(m).sealevelaltitude, 0); %meters
            
    d(m).fakeflag = 1;
    d(m).fake.waterdepth = -4000;
    d(m).fake.detectordepth = -3500;
    d(m).fake.sealevelaltitude = 0;
    if d(m).fakeflag    %FAKE DEPTH -> ADD TO 'updateDetectors.m' ALSO!!!!
        d(m).waterdepth         = d(m).fake.waterdepth;
        d(m).detectordepth      = d(m).fake.detectordepth;
        d(m).sealevelaltitude   = d(m).fake.sealevelaltitude;
    end
    
    d(m).dutycycle = [];
    d(m).range = norm(ecef - input.reactor.positionECEF);
    d(m).number = m;
    d(m).mass = input.detectorMass;
    d(m).nprotons = input.detectorProtons; %scale from kamland
    d(m).z = [];
    d(m).ztruth = [];
    d(m).zsigma = [];
    d(m).est = [];
    d(m).reactors = []; [r, dx] = fcnrange(ecef, [input.reactor.IAEAdata.unique.ecef; input.reactor.positionECEF]); d(m).reactors.udxecef=fcnvec2uvec(dx, r); d(m).reactors.r=r;
    d(m).kr = []; [r, dx] = fcnrange(ecef, input.reactor.IAEAdata.unique.ecef); d(m).kr.udxecef=fcnvec2uvec(dx, r); d(m).kr.r=r; d(m).kr.ni=numel(r);
    d(m).crust = [];
    d(m).mantle.udxecef=table.udx.ned*d(m).DCM_NED2ECEF';  [r, dx, rs]=fcnrange([-norm(ecef) 0 0], table.mantle.ecef);  
    d(m).mantle.r = r;  
    d(m).mantle.ri = uint16(fcnindex1(table.mev.r, r));
    d(m).mantle.eli = fcnindex1(table.udx.el, asind(-dx(:,1)./r)); %elevation indices
    d(m).mantle.sa = (cm2km^2)./rs;
    d(m).nonneutrinos = [];
    d(m).epdf = [];
    d(m).aepdf = [];
    d(m).n = [];
    d(m).snr = [];

    %NONNEUTRINO BACKGROUNDS
    d(m) = fcngetnonneutrinos(d(m), input, stable);
    %d(1).dutycycle.all = 1;
    d(m) = fcnintegratecrust(d(m), stable, 1, .01, 30);
    [d(m).n, d(m).epdf, d(m).aepdf] = fcnmeanspectra(input, stable, d(m), 0);
    d(m) = fcnsnr(input, stable, d(m));
    d(m) = fcnSingleDetector(d(m), table, input);
    
    title('New Detector Placed.','Fontsize',20)
       
    updatePlots
else %place a new reactor
    input.reactor.position = [xi yi];
    input.reactor.positionLLA = lla;
    input.reactor.positionECEF = lla2ecef(lla);
    handles.reactorPoint = plot(xi,yi,'Marker','o','MarkerSize',10,'MarkerEdgeColor',[.8 .8 .8],'MarkerFaceColor','r');

    if flags.explosion
        handles.reactorText = text(xi,yi,sprintf('   Explosion\n   %.1fkTon ',input.reactor.power),'HorizontalAlignment','Left','FontSize',10,'FontWeight','normal');
        title(sprintf('%.1fkTon Nuclear Explosion Placed.',input.reactor.power),'Fontsize',25)
    else
        handles.reactorText = text(xi,yi,sprintf('   Reactor\n   %.1fGWth ',input.reactor.power),'HorizontalAlignment','Left','FontSize',10,'FontWeight','normal');
        title('New Reactor Placed.','Fontsize',20)
    end
    flags.reactorPlaced=1;
end


%CLEAR UNNEEDED VARIABLES -------------------------------------------------
clear xi yi m hcmenu mstr r rs rMat lat lng cmPerkm lla ecef dx
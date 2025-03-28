% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

clc

nd=100;  input.detectorCollectTime=365/nd; %days
LLA = [linspace(39.8,34.4,nd)' linspace(-11.5,-9,nd)' zeros(nd,1)];
x = lla2ecef(LLA);

fname = sprintf('%s (%.0fdays, %.0fframes, %.0fkm, %.0fkmCA), %s %s 1.avi', ...
    input.scenario, input.detectorCollectTime*nd, nd, fcnrange(x(1,:),x(end,:)), min(fcnrange(x,input.reactor.positionECEF)), ...
    table.d(input.di).name, table.d(input.di).detector.prettyvolume);
aviobj = avifile(fname);

flags.status.verbose=1;
flags.status.waterprior=0;
flags.upsample=0;
flags.status.mapGoogle=1;  [~, input]=fcnGetGoogleMap(input, flags);

L = zeros(input.nxy^2, input.nrp);
e = input.fluxnoise.systematic.estimated;
newHandles = [];
ii=1;
 for ii = 1:nd
     %PLACE DETECTOR -------------------------------------------------------
     xy = fcnLLA2GoogleMapsXY(input,LLA(ii,:));
     xi = xy(1); yi = xy(2);  clear lla
     create1Detector
    
    %RUN ESTIMATOR --------------------------------------------------------
    deleteh(newHandles); newHandles = [];
    d1=d(ii);  startclock=clock;  fprintf(' D%.0f...',d1.number)
    [Bi, ~, d1]=fcnenergycut(input, flags, table, d1);
    Si = interp1q(d1.est.urtable.r, d1.est.urtable.n, d1.est.r) * input.rpVec; %number of events from unknown source
    
    Ti = Bi+Si; %Bi = # background events, Ti = # total events
    %Ci = numel(d1.z.eic); %Ci = # candidate measurements
    Ci = d1.n.all;
    
    %ML2-------------------------------------------------------------------
    if Ci>0
        %zn = accumarray(d1.z.eic, 1, [table.mev.ne 1]); %measurements per bin;
        zn = d1.epdf.all*table.mev.de;
        
        zei = find(zn);  zn=zn(zei);  ne=numel(zei);
        %epdf =  (e(1)*d1.epdf.kr + e(2)*d1.epdf.mantle + e(3)*d1.epdf.crust + e(4)*d1.epdf.fastneutron + e(5)*d1.epdf.accidental + e(6)*d1.epdf.cosmogenic);
        epdf = d1.epdf.allbackground;
        
        nr = numel(d1.est.urtable.n);
        bpdf = ones(nr,1)*epdf(zei); %background pdf
        urpdf = d1.est.urtable.epdf(:,zei);
        
        a = zeros(nr, input.nrp, ne);
        for i = 1:input.nrp
            a(:,i,:) = urpdf*input.rpVec(i) + bpdf;
        end
        a = log(a);
        
        b = zeros(nr, input.nrp);
        for i = 1:ne
            b = b + a(:,:,i)*zn(i);
        end
        L = L + interp1q(d1.est.urtable.r, b, d1.est.r) - log(Ti)*Ci;
    end
    %ML1-------------------------------------------------------------------
    s = sqrt(Bi*1.025 + d1.est.br1s^2 + d1.est.d1s^2); %count 1 sigma
    L = L + (- log(sqrt(2*pi)*s) - (Ci-Ti).^2./(2*s.^2));
    MLplot
    %FINISHED ESTIMATOR ---------------------------------------------------
    
    hf=findobj(newHandles,'Type','figure');  ha=get(hf,'Children');
    xy = fcnLLA2GoogleMapsXY(input,LLA);
    plot3(ha(1),xy(1:ii-1,1),xy(1:ii-1,2), ones(ii-1,1)*1,'o','MarkerSize',5,'MarkerEdgeColor',[.8 .8 .8],'MarkerFaceColor',[.6 .6 .6])
    hold(ha(3),'on'); plot(ha(3),xy(1:ii-1,1),xy(1:ii-1,2),'o','MarkerSize',5,'MarkerEdgeColor',[.8 .8 .8],'MarkerFaceColor',[.6 .6 .6])
    
    %GRAB SCREENSHOT ------------------------------------------------------
    hf=findobj(newHandles,'Type','figure');
    aviobj = addframe(aviobj,getframe(hf));  delete(hf);
    
    %CLEAR STUFF ----------------------------------------------------------
    set([handles.detectorPoints(ii) handles.detectorText(ii)],'Visible','off');
    d(ii).z.geoapdf=[];
    d(ii).crust = [];
    d(ii).aepdf = [];
end
aviobj = close(aviobj);











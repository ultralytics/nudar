% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

clc

% **** MUST PUT THIS IN AS OBSERVATION TIME IN INIT.M **** -----------------------
nd=30;  %input.detectorCollectTime=365/nd; %days
% **** MUST PUT THIS IN AS OBSERVATION TIME IN INIT.M **** -----------------------

%LLA = [linspace(39.8,34.4,nd)' linspace(-11.5,-9,nd)' zeros(nd,1)]; %portugal
LLA = [linspace(29.558,28.274,nd)' linspace(50.232,50.865,nd)' zeros(nd,1)]; %portugal
x = lla2ecef(LLA);

fname = sprintf('%s (%.0fdays, %.0fframes, %.0fkm, %.0fkmCA), %s %s 1.avi', ...
     input.scenario, input.detectorCollectTime*nd, nd, fcnrange(x(1,:),x(end,:)), min(fcnrange(x,input.reactor.positionECEF)), ...
     table.d(input.di).name, table.d(input.di).detector.prettyvolume);
vidObj = VideoWriter(fname);  open(vidObj);

flags.status.verbose=1;
flags.status.waterprior=0;
flags.upsample=0;
flags.status.mapGoogle=1;  [~, input]=fcnGetGoogleMap(input, flags);

L = zeros(input.nxy^2, input.nrp);
e = input.fluxnoise.systematic.estimated;
newHandles = [];
%flags.upsample = 1;
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
    Si = interp1(d1.est.urtable.r, d1.est.urtable.n, d1.est.r) * input.rpVec; %number of events from unknown source
    
    Ti = Bi+Si; %Bi = # background events, Ti = # total events
    Ci = numel(d(ii).z.eic); %Ci = # candidate measurements
    %Ci = d1.n.all; %CRLB
    
     %ML3-------------------------------------------------------------------
    if flags.status.ML3 && Ci>0
        Ci = input.dValid.validevents(iv); %Ci = # candidate measurements
        ae1=fcnprob3(input, table, d1, flags);  d1.est.ae1=ae1;  
        allb = (ae1.kr*e(1) + ae1.mantle*e(2) + ae1.crust*e(3) + ae1.fn*e(4) + ae1.acc*e(5) + ae1.cosm*e(6))*sk;
        
        nb = ceil(Ci/nbatch); %number of batches
        i2 = fcnindex1(d1.est.urtable.r, d1.est.r, '*exact');  i1=floor(i2);  i3=ceil(i2);  f=i2-i1; %range interpolant coefficients
        for ib  = 1:nb %number of 100-measurement batches
            v0 = (nbatch*ib-nbatch+1):min(nbatch*ib,Ci);  v1=1:numel(v0);  ei=d1.z.ei(v0);  Lb=allb(v0);  Lc=om1;
            ctip = fcnindex1(d1.snr.ct, d1.est.puvec*d1.z.udxecef(v0,:)'); %cosine theta params
            for i = v1
                ev=urtable_epdf(:,ei(i));  e1=ev(i1);  epdf=e1+f.*(ev(i3)-e1);
                pdfur(:,i) = epdf.*d1.snr.apdf(ctip(:,i));
            end
            for j = vnrp
                Lbj = Lb*irpscale(j);
                Lc1=ov1;
                for i = v1
                    Lc1 = Lc1.*(Lbj(i)+pdfur(:,i));
                end
                Lc(:,j)=Lc1;
            end
            x=fcnminmax(Lc);
            L = L + log(Lc/sk); %fcnminmax(Lc)
        end
        g = ov1*irpscale; %normalize denominator
        L = L - log(Ti.*g)*Ci;
    end
    
%     %ML2-------------------------------------------------------------------
%     if Ci>0
%         zn = accumarray(d1.z.eic, 1, [table.mev.ne 1]); %measurements per bin; %CRLB
%         %zn = d1.epdf.all*table.mev.de;
%         
%         zei = find(zn);  zn=zn(zei);  ne=numel(zei);
%         epdf =  (e(1)*d1.epdf.kr + e(2)*d1.epdf.mantle + e(3)*d1.epdf.crust + e(4)*d1.epdf.fastneutron + e(5)*d1.epdf.accidental + e(6)*d1.epdf.cosmogenic);
%         %epdf = d1.epdf.allbackground; %CRLB
%         
%         nr = numel(d1.est.urtable.n);
%         bpdf = ones(nr,1)*epdf(zei); %background pdf
%         urpdf = d1.est.urtable.epdf(:,zei);
%         
%         a = zeros(nr, input.nrp, ne);
%         for i = 1:input.nrp
%             a(:,i,:) = urpdf*input.rpVec(i) + bpdf;
%         end
%         a = log(a);
%         
%         b = zeros(nr, input.nrp);
%         for i = 1:ne
%             b = b + a(:,:,i)*zn(i);
%         end
%         L = L + interp1(d1.est.urtable.r, b, d1.est.r) - log(Ti)*Ci;
%     end
    
    %ML1-------------------------------------------------------------------
    s = sqrt(Bi*1.025 + d1.est.br1s^2 + d1.est.d1s^2); %count 1 sigma
    L = L + (- log(sqrt(2*pi)*s) - (Ci-Ti).^2./(2*s.^2));
    
    
    %FINISHED ESTIMATOR ---------------------------------------------------
    MLplotLeftOnly

        
    hf=findobj(newHandles,'Type','figure');  ha=get(hf,'Children');
    xy = fcnLLA2GoogleMapsXY(input,LLA);
    %plot3(ha(1),xy(1:ii-1,1),xy(1:ii-1,2), ones(ii-1,1)*1,'o','MarkerSize',5,'MarkerEdgeColor',[.8 .8 .8],'MarkerFaceColor',[.6 .6 .6])
    hold(ha(3),'on'); plot(ha(3),xy(1:ii-1,1),xy(1:ii-1,2),'o','MarkerSize',5,'MarkerEdgeColor',[.8 .8 .8],'MarkerFaceColor',[.6 .6 .6])
    
    %GRAB SCREENSHOT ------------------------------------------------------
    hf=findobj(newHandles,'Type','figure');
    %aviobj = addframe(aviobj,getframe(hf));  delete(hf);
    
    %CLEAR STUFF ----------------------------------------------------------
    set([handles.detectorPoints(ii) handles.detectorText(ii)],'Visible','off');
    d(ii).z.geoapdf=[];
    d(ii).crust = [];
    d(ii).aepdf = [];
    
    set(handles.GUI.figure1,'units','pixels');
    pos = get(handles.GUI.figure1,'position');
    set(handles.GUI.figure1,'units','normalized');
    
    frame = getscreen(pos + [-9 230 18 93]);
    %figure; imshow(frame.cdata)
    writeVideo(vidObj,getframe(hf));
    delete(hf);
end
close(vidObj);











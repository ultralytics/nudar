function [handles, MC] = fcnML123neutron(input,handles,flags,d,table)
newHandles = []; MC = [];
flags.status.CRLB = 0;
flags.status.ML3 = 1;
deleteh(handles.ML123);
clc

if input.dValid.count<1 || (flags.status.ML1==0 && flags.status.ML2==0 && flags.status.ML3==0)
    return
end

fprintf('Running ML123...'); startclock = clock; %#ok<NASGU>
om1     = ones(input.nxy^2, input.nrp);
L       = zeros(input.nxy^2, input.nrp);
ov1     = ones(input.nxy^2, 1);
nbatch  = 50; %number of measurments per batch max
sk      = table.mev.de/4/pi; %stabilizing constant
pdfur   = zeros(input.nxy^2, nbatch);
vnrp    = uint16(1:input.nrp);
e       = input.fluxnoise.systematic.estimated;

nv      = input.dValid.count;
Civ     = zeros(nv,1);
Tiv     = zeros([size(L) nv]);
rpscale = input.rpVec;  irpscale=1./rpscale;
load('neutronconefits.mat');  fit1=fits{1};  fit3=fits{3}; %#ok<*USENS>

table.neutron.al = .215; %(km) attenuation length at sea level. 215m attenuation at sea level leaves 1% alive at 1km.
for iv = 1:nv
    id=input.dValid.idx(iv);  d1=d(id);  fprintf(' D%.0f...',d1.number)
    %     [Bi, ~, d1]=fcnenergycut(input, flags, table, d1);  urtable_epdf = d1.est.urtable.epdf*sk; %maintain numerical integrity
    %     Si = interp1(d1.est.urtable.r, d1.est.urtable.n, d1.est.r) * rpscale; %number of events from unknown source
    %     Ti = Bi+Si; %Bi = # background events, Ti = # total events
    %     Ci = input.dValid.validevents(iv); %Ci = # candidate measurements
    %     if flags.status.CRLB && ~flags.status.ML3
    %         Ci = d1.n.all;
    %     end
    [~, ~, d1]=fcnenergycut(input, flags, table, d1);
    
    d1.est.neutron.t                = input.detectorCollectTime*24*3600; % (s)
    d1.est.neutron.Puluminosity     = 6.1E4; % (n/s/kgWGP) Weapons Grade Plutonium WGP = 6% Pu240, 94% Pu239
    d1.est.neutron.areaperface      = 100^2; %detector area (cm^2)
    d1.est.neutron.es               = 0.160; %signal efficiency
    d1.est.neutron.eb               = 0.065; %background efficiency

    [Bi, Si, Ci, Si1, Cisb] = fcnTi(input,table,d1);
    Si = Si*rpscale;
    Ti = Bi+Si; %Bi = # background events, Ti = # total events
    
    d1.n.allbackground = Bi;
    d1.est.d1s = Bi*.01;
    d1.est.br1s = sqrt(Bi);
    
    
    %MAKE MEASUREMENTS ----------------------------------------------------
    d1 = fcngetPudata(d1,table);
    d1.epdf.fastneutron = d1.epdf.fastneutron./sum(d1.epdf.fastneutron*table.mev.de)*Bi;
    d1.epdf.puneutron = d1.epdf.puneutron./sum(d1.epdf.puneutron*table.mev.de)*Si1;
    d1.epdf.all = d1.epdf.fastneutron+d1.epdf.puneutron;
    d1.epdf.allbackground = d1.epdf.fastneutron;
    
    d1.snr.theta = linspace(0,pi,1000);
    d1.snr.apdf  = fcnthetapdf(1, d1.snr.ct);
    d1.snr.apdf1 = fit1(d1.snr.theta);
    d1.snr.apdf3 = fit3(d1.snr.ct);
    
    %Background Measurements
    n = Cisb(2);
    eb = fcnrandcdf(cumsum(d1.epdf.fastneutron),table.mev.evis,n);
    v0 = isovecs(n); %true vec
    [udxecefb, zab] = fcngetanglemeasurements(d1,input,v0);
   
    %Signal Measurements
    n = Cisb(1);
    es = fcnrandcdf(cumsum(d1.epdf.puneutron),table.mev.evis,n);
    v0 = repmat(fcnvec2uvec(input.reactor.positionECEF - d1.positionECEF),[n 1]); %true vec
    [udxecefs, zas] = fcngetanglemeasurements(d1,input,v0);
    
    d1.z.e = [eb; es];
    d1.z.udxecef = [udxecefb; udxecefs];
    d1.z.eic = fcnindex1(table.mev.evis,d1.z.e); %energy indices of candidates
    d1.z.coneangle = [zab; zas];
    
    %NEUTRON RANGE EPDF LOOKUP TABLE --------------------------------------
    if  1 || ~isfield(d1,'est') || isempty(d1.est)
        [d1.est.r, dx] = fcnrange(d1.positionECEF, input.google.maps.ECEF); %ranges, 40,000x1
        d1.est.puvec = fcnvec2uvec(dx, d1.est.r);
        
        [minr, maxr] = fcnminmax(d1.est.r);
        nr = round(input.nxy*2);  dr=table.mev.r(2)-table.mev.r(1);
        %r=linspace(max(minr-.1,table.mev.r(1)), maxr+.1, nr)';
        r=linspace(max(minr-.1,.001), maxr+.1, nr)'; %km
        %ri = uint16(1:fcnindex1(table.mev.r, max(r)+10));  %max ri
        %fs=interp1(table.mev.r(ri,:),table.mev.fs(ri,:), r);  s=fcnspec1s(table.mev.eall, r, [], 0, 1, 1, table.mev.pdf0*d1.dutycycle.all, fs);
        %s.epdf=fcnsmearenergy(input, table, table.mev.eall, s.s, table.mev.e);  s.r=r;  s.n=sum(s.epdf,2)*table.mev.de;
        %d1.est.urtable=s;
        
        t =     d1.est.neutron.t; % (s)
        n =     d1.est.neutron.Puluminosity; % (n/s/kgWGP) Weapons Grade Plutonium WGP = 6% Pu240, 94% Pu239
        area =  d1.est.neutron.areaperface; %detector area (cm^2)
        es =    d1.est.neutron.es; %signal efficiency
        eb =    d1.est.neutron.eb; %background efficiency

        s.s = (n*exp(-r/table.neutron.al)./(4*pi*( r*1000*100 ).^2)*area*t*es)   *   (d1.epdf.puneutron/sum(d1.epdf.puneutron*table.mev.de)); %flux
        s.epdf=fcnsmearenergy(input, table, table.mev.eall, s.s, table.mev.e);  s.r=r;  s.n=sum(s.epdf,2)*table.mev.de;
        d1.est.urtable=s;
        urtable_epdf = d1.est.urtable.epdf*sk;
        fprintf(' Building range count lookup table')
    end
    

    %     %ML3-------------------------------------------------------------------
    %     if flags.status.ML3 && Ci>0
    %         Ci = input.dValid.validevents(iv); %Ci = # candidate measurements
    %         ae1=fcnprob3(input, table, d1, flags);  d1.est.ae1=ae1;
    %         allb = (ae1.kr*e(1) + ae1.mantle*e(2) + ae1.crust*e(3) + ae1.fn*e(4) + ae1.acc*e(5) + ae1.cosm*e(6))*sk;
    %
    %         nb = ceil(Ci/nbatch); %number of batches
    %         i2 = fcnindex1(d1.est.urtable.r, d1.est.r, '*exact');  i1=floor(i2);  i3=ceil(i2);  f=i2-i1; %range interpolant coefficients
    %         for ib  = 1:nb %number of 100-measurement batches
    %             v0 = (nbatch*ib-nbatch+1):min(nbatch*ib,Ci);  v1=1:numel(v0);  ei=d1.z.ei(v0);  Lb=allb(v0);  Lc=om1;
    %             ctip = fcnindex1(d1.snr.ct, d1.est.puvec*d1.z.udxecef(v0,:)'); %cosine theta params
    %             for i = v1
    %                 ev=urtable_epdf(:,ei(i));  e1=ev(i1);  epdf=e1+f.*(ev(i3)-e1);
    %                 pdfur(:,i) = epdf.*d1.snr.apdf(ctip(:,i));
    %             end
    %             for j = vnrp
    %                 Lbj = Lb*irpscale(j);
    %                 Lc1=ov1;
    %                 for i = v1
    %                     Lc1 = Lc1.*(Lbj(i)+pdfur(:,i));
    %                 end
    %                 Lc(:,j)=Lc1;
    %             end
    %             x=fcnminmax(Lc);
    %             L = L + log(Lc/sk); %fcnminmax(Lc)
    %         end
    %         g = ov1*irpscale; %normalize denominator
    %         L = L - log(Ti.*g)*Ci;
    %     end   
    %ML3-------------------------------------------------------------------
    if flags.status.ML3 && Ci>0
        allb = (d1.epdf.fastneutron(d1.z.eic)/(4*pi)) * sk; %this is equal to ae1.fn!

        nb = ceil(Ci/nbatch); %number of batches
        i2 = fcnindex1(d1.est.urtable.r, d1.est.r, '*exact'); i2=max(i2,1);  i1=floor(i2);  i3=ceil(i2);  f=i2-i1; %range interpolant coefficients
        nk = fcnnormalizeconeangle(fit1,d1.z.coneangle'); %normalizing constant
        for ib  = 1:nb %number of 100-measurement batches
            v0 = (nbatch*ib-nbatch+1):min(nbatch*ib,Ci);  v1=1:numel(v0);  ei=d1.z.eic(v0);  Lb=allb(v0);  Lc=om1;
            ct = d1.est.puvec*d1.z.udxecef(v0,:)';
            %ctip = fcnindex1(d1.snr.ct, ct); %cosine theta params
            
            for i = v1
                ev=urtable_epdf(:,ei(i));  e1=ev(i1);  epdf=e1+f.*(ev(i3)-e1);
                %apdf = d1.snr.apdf(ctip(:,i));
                
                anglei = d1.z.coneangle(v0(i));
                theta1 = abs(acos(ct(:,i)) - anglei);
                apdf = fit1(theta1)*nk(v0(i));
                
                pdfur(:,i) = apdf.*epdf;
            end
            
            for j = vnrp
                Lbj = Lb*irpscale(j);
                Lc1 = ov1;
                for i = v1
                    Lc1 = Lc1.*(Lbj(i)+pdfur(:,i));
                end
                Lc(:,j) = Lc1;
            end
            
            Lcn = Lc*(1/sk);
            L1 = log(Lcn);
            L = L + L1; %fcnminmax(Lc)
        end
        g = ov1*irpscale; %normalize denominator
        L = L - log(Ti.*g)*Ci;
    end
    
    
    %     %ML2-------------------------------------------------------------------
    %     if flags.status.ML2 && Ci>0
    %         zn = accumarray(d1.z.eic, 1, [table.mev.ne 1]); %measurments per bin;
    %         epdf = e(1)*d1.epdf.kr + e(2)*d1.epdf.mantle + e(3)*d1.epdf.crust + e(4)*d1.epdf.fastneutron + e(5)*d1.epdf.accidental + e(6)*d1.epdf.cosmogenic;
    %         if flags.status.CRLB
    %            zn = d1.epdf.all*table.mev.de;
    %            epdf = d1.epdf.allbackground;
    %         end
    %
    %         zei=find(zn);  zn=zn(zei);  ne=numel(zei);
    %         nr = numel(d1.est.urtable.n);
    %         bpdf = ones(nr,1)*epdf(zei); %background pdf
    %         urpdf = d1.est.urtable.epdf(:,zei);
    %
    %         a = zeros(nr, input.nrp, ne);
    %         for i = 1:input.nrp
    %             a(:,i,:) = urpdf*rpscale(i) + bpdf;
    %         end
    %         a = log(a);
    %
    %         b = zeros(nr, input.nrp);
    %         for i = 1:ne
    %             b = b + a(:,:,i)*zn(i);
    %         end
    %
    %         L = L + interp1(d1.est.urtable.r, b, d1.est.r) - log(Ti)*Ci;
    %     end
    if flags.status.ML2 && Ci>0
        zn = accumarray(d1.z.eic, 1, [table.mev.ne 1]); %measurments per bin;
        epdf = d1.epdf.fastneutron;
        %     if flags.status.CRLB
        %         zn = d1.epdf.all*table.mev.de;
        %         epdf = d1.epdf.allbackground;
        %     end
        
        zei=find(zn);  zn=zn(zei);  ne=numel(zei);
        nr = numel(d1.est.urtable.n);
        bpdf = ones(nr,1)*epdf(zei); %background pdf
        urpdf = d1.est.urtable.epdf(:,zei);
        
        a = zeros(nr, input.nrp, ne);
        for i = 1:input.nrp
            a(:,i,:) = urpdf*rpscale(i) + bpdf;
        end
        a = log(a);
        
        b = zeros(nr, input.nrp);
        for i = 1:ne
            b = b + a(:,:,i)*zn(i);
        end
        
        L = L + interp1(d1.est.urtable.r, b, d1.est.r) - log(Ti)*Ci;
    end    
    
    %ML1-------------------------------------------------------------------
    Tiv(:,:,iv)=Ti;  Civ(iv)=Ci;
    
    
    d(id)=d1;
    %D1--------------------------------------------------------------------
    if iv==1
        L1=L;
    end
    
    af = 100-exp(-d1.range/table.neutron.al)*100;
    set(handles.detectorText(id),'String', sprintf('  D%.0f\n  %.0f signal (%.1fm, %.0f%% attenuate)\n  %.0f background',id,Si1,d1.range*1E3,af,Bi),'color',[.7 .7 .7]);
end
set(handles.reactorText,'String',sprintf('  %.1fkg Plutonium',input.reactor.power),'color',[.7 .7 .7]);


C = fcndcorr(input, d); %cov mat
Ln = lognormal(Civ(1), Tiv(:,:,1), sqrt(C(1,1))); L1 = L1+Ln;
if nv>1
    [~,Ln]=fcnmultinormpdf(Tiv,Civ,C);  L=L+Ln;
else
    L = L1;
end
%L = fcnrpprior(input, flags, L); %reactor power prior

MLplot
handles.ML123 = newHandles;
h1 = findobj(newHandles,'type','axes');
if numel(h1)>0; 
    zlabel(h1,'Plutonium Mass (kg)');
    title(h1,sprintf('%.1f%% confidence volume = %0.0f m^2kg (%.0fm^2 at true mass)\nisosurface density = %0.3g', input.CEValue, MC.enclosedvol*1E6,enclosedArea*1E6,isovalue))
end
title(handles.GUI.axes1,sprintf('%.1f%% confidence volume = %0.0f m^2kg (%.0fm^2 at true mass)', input.CEValue, MC.enclosedvol*1E6,enclosedArea*1E6))

end

function p = lognormal(x,u,s)
p = - log(sqrt(2*pi)*s) - (x-u).^2./(2*s.^2);
end

function [Bi, Si, Ci, Si1, Cisb] = fcnTi(input,table,d1)
t =     d1.est.neutron.t; % (s)
n =     d1.est.neutron.Puluminosity; % (n/s/kgWGP) Weapons Grade Plutonium WGP = 6% Pu240, 94% Pu239
area =  d1.est.neutron.areaperface; %detector area (cm^2)
es =    d1.est.neutron.es; %signal efficiency
eb =    d1.est.neutron.eb; %background efficiency

Si =                      n*exp(-d1.est.r/table.neutron.al)./(4*pi*( d1.est.r*1000*100 ).^2)*area*t*es; %flux (n/area/time)
Si1 = input.reactor.power*n*exp(-d1.range/table.neutron.al)./(4*pi*( d1.range*1000*100 ).^2)*area*t*es;
Bi = .0134*(area*3)*t*eb; %.0134 Goldhagen (n/cm^2/s) %Only multiply by 3 sides per Pieter Mumm
Bi = Bi/3; %SATO OVER WATER https://mail.google.com/mail/u/0/?shva=1#search/water/14056204ed8c753b

Cisb(1) = fcnRandomPoisson(Si1);
Cisb(2) = fcnRandomPoisson(Bi);
Ci = sum(Cisb);
end


function  d1 = fcngetPudata(d1,table)
load Puneutronenergy.mat
epdfx = e;  dx = e(2)-e(1);
epdfy = pdfs;

%x = table.mev.evis;
%dx = x(2)-x(1);
%epdfy = fcnanalyticneutronspectrum(x);
%epdfy = epdfy/sum(epdfy)/dx;

epdfy = interp1(epdfx',epdfy',table.mev.e,'linear',epdfy(end));  epdfy = epdfy/sum(epdfy)/dx;
d1.epdf.puneutron = epdfy;
end


function [udxecefs, zas] = fcngetanglemeasurements(d1,input,v0)
%v0 = true vector to add noise about
load neutronz.mat %loads v1 and angle
n0 = size(v0,1);
n1 = size(v1,1); %#ok<*NODEF>
j = ceil(rand(n1*10,1)*n1); v1 = v1(j,:);  angle = angle(j,:); %random MC reordering

i = mod(1:n0,n1); i(i==0)=n1; %re-use measurements if necessary
roll = pi*(2*rand(n0,1)-1);
udxecefs = fcnrotateW2B(roll,fcnel(v0),fcnaz(v0),v1(i,:));
zas = angle(i); %z angle

% r = 0*(2*pi)*(rand(ns,1)-.5); %random roll
% pnoise = 1*randsign(ns).*fcnrandcdf(cumsum(d1.snr.apdf1),d1.snr.theta,ns); %random pitch noise
% p = .2; %randsign(ns).*acos(fcnrandcdf(cumsum(d1.snr.apdf3),d1.snr.ct,ns)); %random pitch
% i = (p+pnoise) > pi; pnoise(i)=-pnoise(i);
% i = (p+pnoise) < 0; pnoise(i)=-pnoise(i);
% 
% v1 = repmat([1 0 0],ns,1);
% v2 = fcnrotateB2W(r,0,p+pnoise,v1);
% v3 = fcnrotateW2B(0,sc0(:,2),sc0(:,3),v2);

% close all
% a = v3';
% b = a*0;
% h=fig(2,2,1.5); axes(h(1)); quiver3(b(1,:),b(2,:),b(3,:),a(1,:),a(2,:),a(3,:));
% axis([-1 1 -1 1 -1 1]); box on; axis equal vis3d; view(18,30); set(gca,'CameraViewAngle',11); fcn3label;
% quiver3(0,0,0,v0(1,1),v0(1,2),v0(1,3),2,'r');
% da = cos(fcnangle(v3,v0));  axes(h(2)); hist(da,30)
% axes(h(3)); plot(d1.snr.theta,d1.snr.apdf1);

% udxecefs = v3; 
% zas = angle(i); %z angle signal
end


function nk = fcnnormalizeconeangle(fit1,angle)
%angle must be column vector!
ct = linspace(-1,1,10000);  dct=ct(2)-ct(1);
x = abs( bsxfun(@minus,acos(ct'),angle) );
nk = (1/2/pi)./sum( reshape(fit1(x),size(x)) * dct);
end


function x2 = fcnrotateW2B(r,p,y,x)
sr=sin(r);  sp=sin(p);  sy=sin(y);
cr=cos(r);  cp=cos(p);  cy=cos(y);
x2 = zeros(size(x));
x2(:,1)=x(:,1).*(cp.*cy)+x(:,2).*(sr.*sp.*cy-cr.*sy)+x(:,3).*(cr.*sp.*cy+sr.*sy);
x2(:,2)=x(:,1).*(cp.*sy)+x(:,2).*(sr.*sp.*sy+cr.*cy)+x(:,3).*(cr.*sp.*sy-sr.*cy);
x2(:,3)=x(:,1).*(-sp)+x(:,2).*(sr.*cp)+x(:,3).*(cr.*cp);
end


function x2 = fcnrotateB2W(r,p,y,x)
sr=sin(r); sp=sin(p); sy=sin(y);
cr=cos(r); cp=cos(p); cy=cos(y);
x2 = zeros(size(x));
x2(:,1)=x(:,1).*(cp.*cy)+x(:,2).*(cp.*sy )+x(:,3).*(-sp);
x2(:,2)=x(:,1).*(sr.*sp.*cy-cr.*sy)+x(:,2).*(sr.*sp.*sy+cr.*cy)+x(:,3).*(sr.*cp);
x2(:,3)=x(:,1).*(cr.*sp.*cy+sr.*sy)+x(:,2).*(cr.*sp.*sy-sr.*cy)+x(:,3).*(cr.*cp);
end

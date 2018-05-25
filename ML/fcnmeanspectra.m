function [n, epdf, ae] = fcnmeanspectra(input, table, d1, addnoiseflag)
fprintf('Building 3D Measurement Space... '); tic
nr                  = input.reactor.IAEAdata.unique.n;
ngeo                = numel(table.mev.smeared.geonu);
zv                  = zeros(1,table.mev.ne);
zvgeo               = zeros(ngeo,table.mev.ne);
epdf.kr             = zv;  epdf.crustv = zvgeo;  epdf.mantlev = zvgeo;
geov1               = uint16(table.mev.geov1);
dc                  = d1.dutycycle.all;
de                  = table.mev.de;
aeflag              = nargout==3;
ngeov1              = numel(geov1);

if addnoiseflag;
    sn                  = input.fluxnoise.systematic;
    un                  = input.fluxnoise.uncorrelated;
    fvu                 = un.rand{3}; fvu=fvu(d1.number);
end


%ALL REACTORS
r=d1.reactors.r;  
fs=interp1(table.mev.r, table.mev.fs, r);
s=fcnspec1s(table.mev.eall, r, [], 0, 1, 1, table.mev.pdf0, fs); %s = fcnspec1s(MeV, r1, op, rp, np, day, r0, f1) %specscaled
epdfallr = s.s; %fcnsmearenergy(input, table, table.mev.eall, s.s, table.mev.e);

%UNKNOWN REACTORS
k1=input.reactor.power*dc;    if addnoiseflag; k1=k1.*sn.rand(1)*fvu; end %add noise
epdf.ur = epdfallr(nr+1,:)*k1;    n.ur=sum(epdf.ur)*de;

%if evalin('base','flags.explosion')
%    [n.ur, epdf.ur] = fcnexplosion(input, table, d1);
%end


%KNOWN REACTORS
k1=input.reactor.IAEAdata.unique.GWth*dc;    if addnoiseflag; k1=k1.*(sn.rand(1)*fvu+un.rand{1}*fvu); end %add noise
e = bsxfun(@times, epdfallr(1:nr,:), k1);
epdf.krv=e;  epdf.kr = sum(e,1);  n.kr=sum(epdf.kr)*de;  n.krv=sum(e,2)*de;
if aeflag
    ae.kr = e;  ae.allr=[ae.kr; epdf.ur];
end


%CRUST
ri=double(d1.crust.ri); %range indices
k = bsxfun(@times,d1.crust.flux,d1.crust.sa*dc);    if addnoiseflag; un1=un.rand{2}; a=sn.rand(3)*fvu+un1(d1.crust.id)*fvu;  k=bsxfun(@times,k,a); end %add noise
e=cell(ngeo,1);
if aeflag
    nri = numel(ri);
    nrt = numel(table.mev.r);
    nai = table.udx.n;
    ae.crust = zeros(nai,ngeov1);
    Sai = sparse(d1.crust.geouvecid,1:numel(d1.crust.geouvecid),1,nai,nri); %sparse angle indices    
    for i=1:ngeo
        aei = Sai*sparse(1:nri,ri,k(:,i),nri,nrt)*table.mev.smeared.geonu{i}; %[4853x385000*385000x15000*15000x430]
        e{i} = sum(aei,1);
        ae.crust = ae.crust+aei;
    end
else
    szb = [input.nr 1];
    for i=1:ngeo
        e{i} = accumarray(ri,k(:,i),szb)' * table.mev.smeared.geonu{i};  
    end
end
epdf.crustv(:,geov1) = cell2mat(e);     epdf.crust = sum(epdf.crustv,1);  %[238U 232TH 40K]
n.crustv = sum(epdf.crustv,2)*de;       n.crust = sum(n.crustv);


%MANTLE
ri=double(d1.mantle.ri); %range indices
k=bsxfun(@times,table.mantle.flux,d1.mantle.sa*dc);     if addnoiseflag; k=k*(sn.rand(2)*fvu); end %add noise
e=cell(ngeo,1);
if aeflag
    val = 1./table.mantle.azperel(d1.mantle.eli);
    nri = numel(ri);
    nai = numel(table.udx.el); %NOT the same as crust nai!!
    nmt = numel(d1.mantle.eli);
    ae.mantle = zeros(table.udx.n,ngeov1);

    Sai = sparse(double(d1.mantle.eli),1:nmt,val,nai,nmt); %sparse angle indices    
    for i=1:ngeo
        aei = Sai*sparse(1:nri,ri,k(:,i),nri,nrt)*table.mev.smeared.geonu{i}; %[4853x385000*385000x15000*15000x430]  
        aej = aei(table.mantle.udxeli,:);
        e{i} = sum(aej,1); 
        ae.mantle = ae.mantle+aej;
    end
else
    for i=1:ngeo
        e{i} = accumarray(ri,k(:,i),szb)' * table.mev.smeared.geonu{i};  
    end
end
epdf.mantlev(:,geov1) = cell2mat(e);    epdf.mantle = sum(epdf.mantlev,1);
n.mantlev = sum(epdf.mantlev,2)*de;     n.mantle = sum(n.mantlev);


%NONNEUTRINOS
nn = d1.nonneutrinos;
k1=nn.fastn_events*dc;     if addnoiseflag; k1=k1.*(sn.rand(4)*fvu); end %add noise
epdf.fastneutron=table.mev.smeared.fastneutron*k1;  n.fastneutron=sum(epdf.fastneutron)*de;
k1=nn.accid_events*dc;     if addnoiseflag; k1=k1.*(sn.rand(5)*fvu); end %add noise
epdf.accidental=table.mev.smeared.accidental*k1;  n.accidental=sum(epdf.accidental)*de;
k1=nn.cosmo_events*dc;     if addnoiseflag; k1=k1.*(sn.rand(6)*fvu); end %add noise
epdf.cosmogenic=table.mev.smeared.cosmogenic*k1;  n.cosmogenic=sum(epdf.cosmogenic)*de;
epdf.nonneutrinos=epdf.fastneutron+epdf.accidental+epdf.cosmogenic;  n.nonneutrinos=sum(epdf.nonneutrinos)*de;


%OUTPUT
epdf.allgeo = epdf.crust+epdf.mantle;  n.allgeo=n.crust+n.mantle;
epdf.allbackground = epdf.kr + epdf.allgeo + epdf.nonneutrinos;  n.allbackground=n.kr+n.allgeo+n.nonneutrinos;
epdf.all = epdf.allbackground+epdf.ur;  n.all=n.allbackground+n.ur;
n.allv = [n.ur n.kr n.crustv(1) n.crustv(2) n.mantlev(1) n.mantlev(2) n.fastneutron n.accidental n.cosmogenic];

urs = sprintf('%.0fkm %.0fMW_{th} Reactor',d1.range,input.reactor.power*1E3);
n.allvlabels = {urs, 'World Reactors', 'Crust ^{238}U', 'Crust ^{232}TH', 'Mantle ^{238}U', 'Mantle ^{232}TH', 'Fast Neutron', 'Accidental', 'Cosmogenic'};

fprintf('Done (%.2fs) ',toc)
end


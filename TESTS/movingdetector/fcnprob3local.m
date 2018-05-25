function [ae1, e1] = fcnprob3local(input, table, d1, flags)

%geo
Ci=numel(d1.z.ge);  zv=zeros(1,Ci);
ae=d1.aepdf;  aecrust=zv;  aemantle=zv;
e=d1.epdf;  ecrust=zv;  emantle=zv;


    nbatch = 2000;
    nb = ceil(Ci/nbatch); 
    for ib  = 1:nb
        v0 = (nbatch*ib-nbatch+1):min(nbatch*ib,Ci);  v1=1:numel(v0);
        r2=fcnindex1(table.mev.e, d1.z.ge(v0), '*exact');  r1=floor(r2);  r3=ceil(r2);
        f=(r2-r1)';
        i1=e.crust(:,r1);  ecrust(v0)=i1+f.*(e.crust(:,r3)-i1);
        i1=e.mantle(:,r1);  emantle(v0)=i1+f.*(e.mantle(:,r3)-i1);
        if flags.status.ML3
            f=ones(table.udx.n,1)*f;
            apdf=d1.snr.apdf( fcnindex1(d1.snr.ct, d1.mantle.udxecef*d1.z.gudxecef(v0,:)') );
            i1=ae.crust(:,r1);  aecrust(v0)=sum((i1+f.*(ae.crust(:,r3)-i1)).*apdf, 1);
            i1=ae.mantle(:,r1);  aemantle(v0)=sum((i1+f.*(ae.mantle(:,r3)-i1)).*apdf, 1);
        end
    end
    clear i1 f apdf


%reactor
ae1.kr = zv;
r2=fcnindex1(table.mev.e, d1.z.e, '*exact');  r1=floor(r2);  r3=ceil(r2);  
f=(r2-r1)';
i1=e.kr(:,r1);  e1.kr=i1+f.*(e.kr(:,r3)-i1);
if flags.status.ML3
    g=ones(input.reactor.IAEAdata.unique.n,1)*f;
    ae1.krapdf=d1.snr.apdf( fcnindex1(d1.snr.ct, d1.kr.udxecef*d1.z.udxecef') );
    i1=ae.kr(:,r1);  epdf=i1+g.*(ae.kr(:,r3)-i1);  ae1.kr=sum(epdf.*ae1.krapdf, 1);
end


%nonneutrinos
i1=d1.epdf.fastneutron(r1);  i3=d1.epdf.fastneutron(r3);  e1.fn = i1+f.*(i3-i1);  ae1.fn=e1.fn/(4*pi);
i1=d1.epdf.accidental(r1);  i3=d1.epdf.accidental(r3);  e1.acc = i1+f.*(i3-i1);  ae1.acc=e1.acc/(4*pi);
i1=d1.epdf.cosmogenic(r1);  i3=d1.epdf.cosmogenic(r3);  e1.cosm = i1+f.*(i3-i1);  ae1.cosm=e1.cosm/(4*pi);

zv = zeros(1,numel(d1.z.e));
e1.crust=zv;    e1.crust(d1.z.gi)=ecrust;
e1.mantle=zv;   e1.mantle(d1.z.gi)=emantle;
ae1.crust=zv;   ae1.crust(d1.z.gi)=aecrust;
ae1.mantle=zv;  ae1.mantle(d1.z.gi)=aemantle;
end
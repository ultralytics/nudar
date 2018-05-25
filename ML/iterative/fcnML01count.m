function [fx1, gx] = fcnML01count(input, d, table, flags, active, x, xactive)
%fx = likelihood of x;   gx = gradient of x;   %x = [1-kr 2-mantle 3-crust 4-fn 5-acc 6-cosm 7-dm12 8-dm13 9-s2t12 10-s2t13];
x(active)=xactive;
na = numel(active);
nx=na+1; fx=zeros(nx,1);
dx=1E-6*[1 1 1 1 1 1 input.osc.est.mu 1]'; dxm=diag(dx);%for gradient
x = [x;  ones(na,1)*x+dxm(active,:)];
jv=[1 active+1];  op1=x(1,7:10);  de=table.mev.de;

krGWth0=input.reactor.IAEAdata.unique.GWth';  krGWth=krGWth0;  krGWth(end)=krGWth(end)*x(1,11); 
for id = 1:input.dValid.count
    d1  = d(input.dValid.idx(id));
    npe = [d1.n.kr; d1.n.mantle; d1.n.crust; d1.n.fastneutron; d1.n.accidental; d1.n.cosmogenic];
    Ci  = input.dValid.validevents(id); %number of candidate measurements   
    rpdf0 = table.mev.pdf0*d1.dutycycle.all;
    
    skr0 = fcnspec1s(table.mev.eall, d1.kr.r, op1, 0, 1, 1, rpdf0);
    if flags.status.ML3
        epdfkr0 = fcnsmearenergy(input, table, table.mev.eall, skr0.s);  npe(1)=sum(krGWth*epdfkr0)*de;
        epdfkr = krGWth*(epdfkr0(:,d1.z.eic).*d1.est.ae1.krapdf);
        z1 = d1.est.ae1;
    else %ML2
        epdfkr = fcnsmearenergy(input, table, table.mev.eall, krGWth*skr0.s);  npe(1)=sum(epdfkr)*de;
        epdfkr = epdfkr(:,d1.z.eic);
        z1 = d1.est.e1;
    end
    
    for i = 1:nx
        x1 = x(i,:); %candidate fraction
        switch jv(i)
            case 1 %normal
            case 2 %kr
            case 3 %mantle
            case 4 %crust
            case 5 %fn
            case 6 %acc
            case 7 %cosm
            case {8,9,10,11} %dm12, dm13, s2t12, s2t13
                skr = fcnspec1s(table.mev.e, d1.kr.r, x1(7:10), 0, 1, 1, rpdf0);
                if flags.status.ML3
                    epdfkr = fcnsmearenergy(input, table, table.mev.e, skr.s);   npe(1)=sum(krGWth*epdfkr)*de;
                    epdfkr = krGWth*(epdfkr(:,d1.z.eic).*d1.est.ae1.krapdf);
                else %ML2
                    epdfkr = fcnsmearenergy(input, table, table.mev.e, krGWth*skr.s);  npe(1)=sum(epdfkr)*de;
                    epdfkr = epdfkr(d1.z.eic);
                end
            case 12
                krGWth=krGWth0;  krGWth(end)=krGWth(end)*x1(11);
                if flags.status.ML3
                    epdfkr = krGWth*(epdfkr0(:,d1.z.eic).*d1.est.ae1.krapdf);  npe(1)=sum(krGWth*epdfkr0)*de;
                else %ML2
                    epdfkr=fcnsmearenergy(input, table, table.mev.eall, krGWth*skr0.s);  npe(1)=sum(epdfkr)*de;
                    epdfkr = epdfkr(:,d1.z.eic);
                end
        end
        Bi=x1(1:6)*npe;  Ti=Bi+0;  Vi=Ti+d1.est.ML31.npebr1s^2;
        
        z1all = x1(1)*epdfkr + x1(2)*z1.mantle + x1(3)*z1.crust + x1(4)*z1.fn + x1(5)*z1.acc + x1(6)*z1.cosm;      
        %fx(i) = fx(i) + sum(log(z1all)) - log(Ti)*Ci - log(sqrt(2*pi*Vi)) - (Ci-Ti).^2./(2*Vi);
        fx(i) = fx(i) - log(sqrt(2*pi*Vi)) - (Ci-Ti).^2./(2*Vi);
    end
end
s=table.osc;  ov=ones(nx,1);  means=[1 1 1 1 1 1 s.u 1];
v1=(x(1,7:10)>=s.u);  os(v1)=s.su(v1);  os(~v1)=s.sl(~v1);  sigmas=[input.fluxnoise.systematic.mean(1:6) os sqrt(6^2/12)];
fx = fx + sum(lognormal(x(1:nx,:), ov*means, ov*sigmas), 2);
fx = - fx;  fx1 = fx(1);% minimize negative log likelihood

if nargout==2; gx=(fx(2:nx)-fx1)./dx(active); end
if flags.status.verbose;  fprintf('%10.3f ',[fx1 x(1,:) Ti Ci]); fprintf('\n');  end
end

function p = lognormal(x,u,s)
p = - log(sqrt(2*pi)*s) - (x-u).^2./(2*s.^2);
end
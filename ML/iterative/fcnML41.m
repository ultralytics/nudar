function [fx, gx] = fcnML41(input, d, table, flags, x)
%fx = likelihood of x
%gx = gradient of x
%x = [1-lat 2-lng 3-rp 4-kr 5-mantle 6-crust 7-fn 8-acc 9-cosm 10-dm12 11-dm13 12-s2t12 13-s2t13];
nx = numel(x);
dx = 1E-6*[10 10 1 1 1 1 1 1 1]'; %for gradient
x = [x;  ones(nx,1)*x+diag(dx)];
if nargout==2; nx=nx+1; else nx=1; end;  fx=zeros(nx,1);

for id = 1:input.dValid.count
    d1  = d(input.dValid.idx(id));
    npe = [d1.n.kr; d1.n.mantle; d1.n.crust; d1.n.fastneutron; d1.n.accidental; d1.n.cosmogenic];
    Ci  = input.dValid.validevents(id); %number of candidate measurements   
    rpdf0 = table.mev.pdf0*d1.dutycycle.all;
    [rur, dxur] = fcnrange(d1.positionECEF, lla2ecef([x(1:3,1:2) zeros(3,1)]) );
    ir = 1 : fcnindex1(table.mev.r, max(rur)+10);    
    f1 = interp1(table.mev.r(ir,:),table.mev.fs(ir,:), rur);
    sur = fcnspec1s(table.mev.e, rur, input.osc.est.mu, 0, 1, 1, rpdf0, f1);
    epdfur = fcnsmearenergy(input, table, table.mev.e, sur.s);  epdfur=epdfur(:,d1.z.eic);
    
    if flags.status.ML3
        z1=d1.est.ae1;
        apdfur = fcnthetapdf(d1.snr.val, fcnvec2uvec(dxur, rur)*d1.z.udxecef');
        epdfur = epdfur.*apdfur;
    else %ML2
        z1=d1.est.e1;
    end
    
    for j = 1:nx
        x1 = x(j,:); %candidate fraction
        switch j
            case 1 %normal
                Si=sur.n(1);
                ur = epdfur(1,:);
            case 2 %dlat
                Si=sur.n(2);
                ur = epdfur(2,:);
            case 3 %dlong
                Si=sur.n(3);
                ur = epdfur(3,:);
            case 4 %drp
                Si=sur.n(1);
                ur = epdfur(1,:);
            case 5 %kr
            case 6 %mantle
            case 7 %crust
            case 8 %fn
            case 9 %acc
            case 10 %cosm
            case {11,12,13,14} %dm12, dm13, s2t12, s2t13
%                 skr = fcnspec1s(table.mev.e, rukr, x1(10:13), 0, 1, 1, rpdf0);
%                 epdfr = fcnsmearenergy(input, table, table.mev.e, ukrGWth*skr.s);
%                 npe(1) = (krGWth*skr.n(1:d1.kr.ni));
        end
        Bi =  x1([4 5 6 7 8 9])*npe; %with cuts
        Ti = Bi+Si*x1(3);
        Vi = Ti + d1.est.ML31.npebr1s^2;
      
        z1all =  x1(3)*ur + x1(4)*z1.kr + x1(5)*z1.mantle + x1(6)*z1.crust + x1(7)*z1.fn + x1(8)*z1.acc + x1(9)*z1.cosm;      
        fx(j) = fx(j) + sum(log(z1all)) - log(Ti)*Ci;
        fx(j) = fx(j) - log(sqrt(2*pi*Vi)) - (Ci-Ti).^2./(2*Vi); %count probability
    end
end
fx = fx + sum( lognormal(x(1:nx,4:9), ones(nx,6), ones(nx,1)*input.fluxnoise.systematic.mean(1:6)) ,2); %systematic gain priors [kr geo fastn acc cosmo]

if flags.status.waterprior;  fx=fx-fcnunderwater(input, 0, x(:,1), x(:,2))'*1E6;  end
fx = - fx; % minimize negative log likelihood
if nargout==2
    gx = (fx(2:nx)-fx(1))./dx; %gradient
end
fx = fx(1);
%fprintf('%10.3f ',[fx x(1,:) Ti Ci]); fprintf('\n')
end

function p = lognormal(x,u,s)
p = - log(sqrt(2*pi)*s) - (x-u).^2./(2*s.^2);
end
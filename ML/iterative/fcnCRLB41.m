function [sx] = fcnCRLB41(input, d, table, flags, x)
%fx = likelihood of x
%gx = gradient of x
%x = [1-lat 2-lng 3-rp 4-kr 5-mantle 6-crust 7-fn 8-acc 9-cosm 10-dm12 11-dm13 12-s2t12 13-s2t13];
nx = numel(x);
dx = [.01 .01 .01 input.fluxnoise.systematic.mean(1:6)*.01]'; %for gradient
x = [x;  ones(nx,1)*x+diag(dx)];
nx=nx+1; fx=zeros(nx,1);

for id = 1:input.dValid.count
    d1  = d(input.dValid.idx(id));
    rpdf0 = table.mev.pdf0*d1.dutycycle.all;
    
    [d1.n, d1.epdf] = fcnmeanspectra(input, table, d1, 0);
    [~, ~, d1] = fcnenergycut(input, flags, table, d1);
    
    [rur, dxur] = fcnrange(d1.positionECEF, lla2ecef([x(1:3,1:2) zeros(3,1)]) );
    ir = 1 : fcnindex1(table.mev.r, max(rur)+10);    
    f1 = interp1(table.mev.r(ir,:),table.mev.fs(ir,:), rur);
    sur = fcnspec1s(table.mev.e, rur, [], 0, 1, 1, rpdf0, f1);
    epdfur = fcnsmearenergy(input, table, table.mev.e, sur.s);
    
    if flags.status.ML3
        %z1=d1.est.ae1;
        %apdfur = fcnthetapdf(d1.snr.val, fcnvec2uvec(dxur, rur)*d1.z.udxecef');
        %epdfur = epdfur.*apdfur;
    else %ML2
        z1=d1.epdf;
    end
    
    for j = 1:nx
        x1 = x(j,:); %candidate fraction
        switch j
            case 1 %normal
                ur = epdfur(1,:);
            case 2 %dlat
                ur = epdfur(2,:);
            case 3 %dlong
                ur = epdfur(3,:);
            case 4 %drp
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
      
        epdf =  x1(3)*ur + x1(4)*z1.kr + x1(5)*z1.mantle + x1(6)*z1.crust + x1(7)*z1.fastneutron + x1(8)*z1.accidental + x1(9)*z1.cosmogenic;
        Ci = sum(epdf)*table.mev.de;
        if j==1
           n1 = epdf*table.mev.de;
           Ci1 = Ci;  d1.n.allbackground = Ci1;
        end

        [~,Ln]=fcnmultinormpdf(Ci, Ci1, fcndcorr(input, d1));
        fx(j) = sum(log(epdf).*n1) - log(Ci)*Ci1;% + Ln;
    end
end
fx = fx + sum( lognormal(x(1:nx,4:9), ones(nx,6), ones(nx,1)*input.fluxnoise.systematic.mean(1:6)) ,2); %systematic gain priors [kr geo fastn acc cosmo]

fx = - fx; % minimize negative log likelihood

dfx = fx(1)-fx(2:nx);
sx = sqrt(dx.^2./abs(2*dfx));
sx(3) = sx(3)*input.reactor.power*1000;
end

function p = lognormal(x,u,s)
p = - log(sqrt(2*pi)*s) - (x-u).^2./(2*s.^2);
end
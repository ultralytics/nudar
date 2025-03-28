% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

function [d1, npeuranium] = fcnintegratecrust(d1, table, aeflag, threshold, maxgen)
npeuranium=0;
if nargin<4
    threshold = 1; %events per tile
    maxgen = 15;
end
tic; 

cmPerkm = 100000;
if ~d1.crustBrokenDownFlag;  fprintf('Breaking Down Crust... ')
    nst1 = 2; %number subtiles along each dim
    nst = nst1^3;
    a = 2; %gen 0 tile size (deg)
    
    c=midspace(-.5,.5,nst1);
    [lat, lng, alt] = meshgrid(c,c,c); lat=lat(:); lng=lng(:); alt=alt(:);

    s           = table.crust.all;%struct
    nt          = s.n; %number of tiles
    [r, ~, rs]  = rangec(d1.positionECEF, s.ecef); %ranges
    ri          = uint16(fcnindex1(table.mev.r, r)); %range rows
    sa          = (1/cmPerkm^2)./rs; %solid angle
    npe         = table.mev.uranium.ns(ri).*s.flux(:,1).*sa*d1.dutycycle.all; %npe from URANIUM FIRST
    
    v2 = uint32(1:nt);
    parentid = uint32(1:nt)'; %original parent tile id
    s.gen = ones(nt,1);
    for gen = 2:maxgen
        v1 = uint32(find(npe(v2)>threshold)) + (v2(1)-1);  nv1 = numel(v1);
        
        if nv1==0 || nt>3E6
            break %exit for loop
        end
        nv2 = nv1*nst;
        
        v3  = reshape(repmat(v1',[nst 1]),nst*nv1,1);    
        lla0 = s.lla(v1,:)';
        lat0 = bsxfun(@plus,lat*a,lla0(1,:));
        lng0 = bsxfun(@plus,lng*a,lla0(2,:));
        alt0 = bsxfun(@plus,(alt*1000)*s.thickness(v1)',lla0(3,:));
        lla8 = zeros(nst*nv1,3);
        lla8(:,1)=lat0(:); lla8(:,2)=lng0(:); lla8(:,3)=alt0(:);

        flux8          = s.flux(v3,:)/nst;
        ecef8          = lla2ecef(lla8);
        %ecef8         = lla2ecefc(lla8);
        [r8, ~, rs8]   = rangec(d1.positionECEF, ecef8); %ranges
        
        ri8            = uint16(fcnindex1(table.mev.r, r8)); %range rows
        sa8            = (1/cmPerkm^2)./rs8; %solid angle
        npe8           = table.mev.uranium.ns(ri8).*sa8.*flux8(:,1)*d1.dutycycle.all;
        
        v2 = uint32((nt+1):(nt+nv2)); %new tiles created
        s.gen(v2) = gen;
        s.lla(v2,:) = lla8;
        s.ecef(v2,:) = ecef8;
        s.flux(v2,:) = flux8;
        s.thickness(v2) = s.thickness(v3)/nst1; %m2km
        npe(v2) = npe8; %add the smaller tiles
        parentid(v2) = parentid(v3);
        
        nt = nt+nv2;
        npe(v1)=0;
        a = a/nst1; %angle
    end
    v4              = npe>1E-15;    npeuranium = sum(npe);

    d1.crust.flux   = s.flux(v4,:);
    d1.crust.gen    = s.gen(v4);
    d1.crust.lla    = s.lla(v4,:);
    d1.crust.ecef   = s.ecef(v4,:);
    d1.crust.id     = parentid(v4); %parent ID
    [r, dx, rs]     = rangec(d1.positionECEF, d1.crust.ecef); %ranges
    d1.crust.r      = r;
    d1.crust.ri     = uint16(fcnindex1(table.mev.r, r));
    d1.crust.sa     = (1/cmPerkm^2)./rs;
    
    if aeflag %get angle indices for aepdf        
        uea = fcnelaz(d1.mantle.udxecef);
        dea = fcnelaz(dx);
        ns = createns(uea,'NSMethod','kdtree');
        d1.crust.geouvecid = knnsearch(ns,dea); %closest geouvec id
    end
    d1.crustBrokenDownFlag = true;
end
fprintf(' Done (%.2fs)',toc)

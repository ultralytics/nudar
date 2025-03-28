% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

function s2 = fcnintegratemantle(s, table)
dc=1;
cmPerkm = 100000;
d1.positionECEF = [-6371.1 0 0];

nt          = numel(s.ri); %number of tiles
[r, ~, rs] = fcnrange(d1.positionECEF, s.ecef); %ranges
ri          = fcnindex1(table.mev.r, r); %range rows
sa          = (1/cmPerkm^2)./rs; %solid angle
npe         = table.mev.uranium.ns(ri).*s.flux(:,1).*sa*dc; %npe from URANIUM FIRST

s.gen = ones(nt,1);
for gen = 2:30
    v1 = find(npe>1);
    nv1 = numel(v1);
    if nv1==0
        break %exit for loop
    end
    nv2 = nv1*4;
    zv = zeros(nv2,1);
    v3  = reshape(ones(4,1)*v1',4*nv1,1);
    
    %a    = 2/2^gen; %angle
    col1 = reshape( (s.arc(v1)/4                 *[-1  1 -1  1])',nv2,1); %az/longitude
    col2 = reshape( (s.thickness(v1)*(1000/4)    *[ 1  1 -1 -1])',nv2,1); %altitude
    lla8 = s.lla(v3,:) + [zv col1 col2];
    
    flux8          = s.flux(v3,:)/4;
    ecef8          = lla2ecef(lla8);
    [r8, ~, rs8] = fcnrange(d1.positionECEF, ecef8); %ranges
    ri8            = fcnindex1(table.mev.r, r8); %range rows
    sa8            = (1/cmPerkm^2)./rs8; %solid angle
    npe8           = table.mev.uranium.ns(ri8).*sa8.*flux8(:,1)*dc;
    
    v2 = (nt+1):(nt+nv2); %new tiles created
    s.gen(v2) = gen;
    s.lla(v2,:) = lla8;
    s.ecef(v2,:) = ecef8;
    s.flux(v2,:) = flux8;
    s.thickness(v2) = s.thickness(v3)/2; %m2km
    s.arc(v2) = s.arc(v3)/2; %m2km
    npe(v2) = npe8; %add the smaller tiles
    
%     dx(v2,:) = dx8;
%     r(v2) = r8;
%     ri(v2) = ri8;
%     sa(v2) = sa8;
    
    nt = nt+nv2;
    npe(v1)=0;
end
v4        = npe>1E-15;
%table.mantle.dx     = dx(v4,:);
%s.r      = r(v4);
%s.ri     = ri(v4);
%s.sa     = sa(v4);
s2.flux   = s.flux(v4,:);
s2.gen    = s.gen(v4);
s2.lla    = s.lla(v4,:);
s2.ecef   = s.ecef(v4,:);
s2.arc    = s.arc(v4);
s2.thickness = s.thickness(v4);
    
end


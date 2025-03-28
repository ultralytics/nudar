% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

function table = fcnmantle(table)
fprintf('Making Mantle... ');tic

np = 50000;
rearth=6371.1; innerRadius=3480; outerRadius=6291;
A=pi*(outerRadius^2-innerRadius^2)/2; A1=A/np; dr1=A1^.5;
dr=outerRadius-innerRadius; nr=round(dr/dr1); dr1=dr/nr;
r = linspace(innerRadius+dr1/2, outerRadius-dr1/2, nr);
circ=2*pi*r/2;  npr=round(circ/dr1);
rv=zeros(2*np,1); av=rv; s.area=rv; s.arc=rv; j=0;
for i=1:nr
    k=npr(i);
    v1=j+1:j+k;
    rv(v1)=r(i);
    daz = 180/k;
    av(v1)=linspace(0+daz/2,180-daz/2,k);
    s.arc(v1) = 180/k;
    s.area(v1) = dr1*pi*r(i)/k;
    j=j+k;
end
v1=1:j; rv=rv(v1); av=av(v1);  s.area=s.area(v1); s.arc=s.arc(v1);
s.ecef = fcnSC2CC(rv, rv*0, av*pi/180); 
s.lla = ecef2lla(s.ecef);
s.thickness(v1,1) = dr1;

cmPerkm     = 100000;
area        = s.area*(cmPerkm^2);
ringVol     = (2*pi*cmPerkm)*abs(s.ecef(:,2)).*area; %cm^3
rEv         = linspace(innerRadius,outerRadius,1000)';
flux        = compute_geoneutrinos_mulliss2(rEv); %#/cm^3/s
irE         = fcnindex1(rEv,rv);

%density     = fcnPREM(rv); %(g/cm^3)
%mass        = ringVol.*density; %(g)

s.r=fcnrange([-rearth 0 0], s.ecef);  s.ri=fcnindex1(table.mev.r, s.r);
s.flux = bsxfun(@times, flux(irE,1:3), ringVol); %#/s in all directions
s.sa = (1/cmPerkm^2)./s.r.^2;
s.layer(v1,1)=1;
table.mantle = fcnintegratemantle(s, table);

%OUTPUT!!!!
del = 3;
el=(-90+del/2:del:90-del/2)';
[table.udx.ned, table.udx.sc, table.mantle.azperel, table.mantle.udxeli] = fcnuniformsphereFixedElevations(el*(pi/180));
table.udx.n = numel(table.mantle.udxeli);
table.udx.el = el;
%figure; fcnplot3(table.udx.ned(1:2000,:),'.'); axis equal vis3d

table.mantle.r1 = innerRadius;
table.mantle.r2 = outerRadius;
table.mantle.rdetector = rearth;

fprintf('Done (%.2fs)\n',toc)
end


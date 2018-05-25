function [cc, sc, azperel, eli, n2] = fcnuniformsphereFixedElevations(elvec)
%cc = x y z unit vectors that make up a uniform sphere

del=elvec(2)-elvec(1);
azvec = -180+del/2 : del : 180-del/2;  naz = numel(azvec);
azvec(ceil(naz/2)) = 0;
nel = numel(elvec);
[azu, elu] = meshgrid(azvec,elvec);
azu = azu./cos(elu);

%spread out rows evenly
n2 = 0;
zv = zeros(50000,1);
eli = zv;
el2 = zv;
az2 = zv;
daNM1 = 0;
azperel = zeros(nel,1);
for i = 1:numel(elvec);
    az = azu(i,:);
    v1 = find(abs(az)<pi);
    n1 = numel(v1);
    v2 = (n2+1):(n2+n1);
    da = 2*pi/n1;
       
    if mod(i,2)==0
        az = mod(linspace(-pi+da/2, pi-da/2, n1),2*pi);
     else
        az = mod(linspace(-pi+da/2, pi-da/2, n1) + daNM1/2,2*pi);
    end
    
    azperel(i) = n1;
    az2(v2) = az;
    el2(v2) = elvec(i);
    eli(v2) = i;
    n2 = n2+n1;
    daNM1 = da;
end
v1 = 1:n2;
eli = eli(v1);
el2 = el2(v1);
az2 = az2(v1);

sc = [ones(n2,1) el2 az2];
cc = fcnSC2CC(1,el2,az2);

% figure; plot(az2, el2, '.')
% figure; plot3(cc(:,1), cc(:,2), cc(:,3),'.'); axis equal vis3d


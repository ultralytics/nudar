% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

clc

[x,y,z] = sphere(100);
xv=reshape(x,numel(x),1);  yv=reshape(y,numel(y),1);  zv=reshape(z,numel(z),1);

v1 = [1 1 1];
[theta, ct0] = fcnangle(v1,[xv yv zv]);
tv = reshape(theta,size(x));

snrv = [.053 .53 1.06 1.59];
for i=1:4
snr=snrv(5-i);
    
apdf = fcnthetapdf(snr, ct0); %dan's eqn;
apdfv = reshape(apdf,size(x));

t = linspace(0,pi,10000); ct=cos(t);
apdf1 = fcnthetapdf(snr, ct).*sin(t);
[~, np]  = fcndsearch(apdf1,0.68269);
t = t(np);

az = linspace(-pi,pi,500)';
ring = 1.005*[ones(500,1)*cos(t) sin(az)*sin(t) cos(az)*sin(t)] * fcnVEC2DCM_B2W(v1)';


%figure; 
sca(h(i))
cla
plot3(v1(1)*[-1 1],v1(2)*[-1 1],v1(3)*[-1 1],'-','color',[.7 .7 .7],'linewidth',1.5); hold on
h1=surf(x,y,z,apdfv); alpha 1
plot3(ring(:,1),ring(:,2),ring(:,3),'--','linewidth',1,'color',[.7 .7 .7])
axis vis3d equal; colorbar; set(gca,'clim',[0 .55])

lighting phong
material shiny
set(h1,'EdgeColor','none','FaceColor','interp','SpecularColorReflectance',.3,'SpecularStrength',.9);
view(41,82)

%lightangle(-45,30)
%lightangle(-45,-45)
%lightangle(-45,-45)
lightangle(130,30)
%lightangle(40,82)

set(findobj(gca,'type','surface'),...
    'FaceLighting','phong',...
    'AmbientStrength',.9,'DiffuseStrength',.3,...
    'SpecularStrength',.3,'SpecularExponent',90,...
    'BackFaceLighting','unlit')
 text(-.36,1,.22,'1\sigma','color',[.7 .7 .7],'fontsize',8)
end

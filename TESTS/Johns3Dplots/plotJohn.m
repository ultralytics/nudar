% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

x=vi; y=vj; z=vk;

[xm,ym,zm]=ndgrid(x,y,z);
v=y0(:,:,:,2); v(v(:,:,:,:)==0)=max3(v);

set(figure,'color','w','units','centimeters','position',[.1 1.1 19 19])

isovalue=0;
n = isosurface(xm,ym,zm,v,isovalue);
p1 = patch(n,'AmbientStrength',1);
set(p1,'FaceColor',[.5 .5 .5],'EdgeColor','none','FaceAlpha',1)
%reducepatch(p1, .8)
isonormals(x,y,z,v,p1) %WTF does this actually do?
lighting phong
material shiny

%x1=1000; light('Position',[0 0 x1-100]);  light('Position',[0 0 x1+100]);  light('Position',[-x1 0 x1]);  light('Position',[0 -500 x1]);  light('Position',[500 0 x1]);  light('Position',[0 500 x1]);  camlight
p2 = patch(isocaps(xm,ym,zm,v,isovalue));
set(p2,'EdgeColor','none','FaceColor','interp','SpecularColorReflectance',0,'SpecularStrength',.3);

c=[1 1 1]*.7;
set(gca,'clim',[0 30],'xcolor',c,'ycolor',c,'zcolor',c)
axis tight vis3d; view(140,32); set(gca,'xdir','reverse')
xlabel('range (km)'); ylabel('sheilding (MWE)'); zlabel('size (m^3)')

box on;
colorbar
fcnfontsize(8)

function d1 = fcnContextPlotAngleSpace(input, flags, table, d1, ~)
tic
scCont = worldContour(input, d1);
gray = [.7 .7 .7];
[~, ~, d1] = fcnenergycut(input, flags, table, d1);

nr = 45; nc = 90;
r = linspace(90,-90,nr); %el
c = linspace(-180,180,nc); %az
[rm, cm] = meshgrid(r, c);
zdxvned = fcnSC2CCd(1, rm(:), cm(:));
zdxvecef = zdxvned*d1.DCM_NED2ECEF';
zm = zeros(nc,nr,table.mev.ne);

d1.z.geoapdf = d1.snr.apdf( fcnindex1(d1.snr.ct, zdxvned*table.udx.ned') );


Zcrustg = reshape(d1.z.geoapdf*d1.aepdf.crust, [nc nr numel(table.mev.geov1)]);
Zmantleg = reshape(d1.z.geoapdf*d1.aepdf.mantle, [nc nr numel(table.mev.geov1)]);
Zcrust=zm;  Zcrust(:,:,table.mev.geov1)=Zcrustg;
Zmantle=zm;  Zmantle(:,:,table.mev.geov1)=Zmantleg;

ni = input.reactor.IAEAdata.unique.n;
ctir = fcnindex1(d1.snr.ct, zdxvecef*d1.reactors.udxecef(1:ni,:)'); 
Zkr = reshape(d1.snr.apdf(ctir)*d1.aepdf.kr, [nc nr table.mev.ne]) ;

ctir = fcnindex1(d1.snr.ct, zdxvecef*d1.reactors.udxecef(ni+1,:)'); 
Zur = reshape(d1.snr.apdf(ctir)*d1.epdf.ur, [nc nr table.mev.ne]);

Zfn=zm;  Zacc=zm;  Zcosm=zm; 
for i = 1:table.mev.ne %add nn
    Zfn(:,:,i) = d1.epdf.fastneutron(i)/(4*pi);
    Zacc(:,:,i) = d1.epdf.accidental(i)/(4*pi);
    Zcosm(:,:,i) = d1.epdf.cosmogenic(i)/(4*pi);
end
% for i = 1:nr %solid angle correction
%     Z(:,i,:) = Z(:,i,:)*cosd(r(i));
% end

Lcells = cell(6,1);
Lcells{1} = Zur; %1. unknown reactor
Lcells{2} = Zkr; %2. known reactors
Lcells{3} = Zmantle; %3. mantle
Lcells{4} = Zcrust; %4. crust
Lcells{5} = Zfn+Zacc+Zcosm; %5. non-neutrinos
Lcells{6} = Zur+Zkr+Zmantle+Zcrust+Lcells{5}; %6. all

titlecells = cell(6,1);
titlecells{1} = sprintf('Unknown Reactor Z (%.2fSNR)',d1.snr.val); %1. unknown reactor
titlecells{2} = sprintf('Known Reactors Z (%.2fSNR)',d1.snr.val); %2. known reactors
titlecells{3} = sprintf('Mantle Z (%.2fSNR)',d1.snr.val);%3. mantle
titlecells{4} = sprintf('Crust Z (%.2fSNR)',d1.snr.val); %4. crust
titlecells{5} = sprintf('Non-Neutrino Z (%.2fSNR)',d1.snr.val); %5. non-neutrinos
titlecells{6} = sprintf('Mixture Distribution Z (%.2fSNR)',d1.snr.val); %6. all
         
hs1=fig(2,3,1.25);    
hs2=fig(2,3,1.25);
hs3=fig(1,1,1.25);

for k = 1:6
    Z=Lcells{k};
    v1e = 1:10:table.mev.ne;
    z = table.mev.e(v1e);
    Z = Z(:,:,v1e);

    %PLOT ISOSURFACE
    sca(hs1(k));
    sc = fcnCC2SC((input.reactor.positionECEF-d1.positionECEF)*d1.DCM_NED2ECEF);
    plot3(sc(2)*[1 1],sc(3)*[1 1],[1.7 max(table.mev.e(v1e))],'r-');
    axis([min(r) max(r) min(c) max(c) min(z) 9.5])
    view(55,20); grid off; axis vis3d; box on; set(gca,'XDir','Reverse');
    ylabel('az (deg)','Units','Normalized','Position',[.7 .05])
    xlabel('el (deg)','Units','Normalized','Position',[.03 .07])
    zlabel('E_{\nu} (MeV)');
    title(titlecells{k},'Units','Normalized','Position',[.5 .975])
    caxis([min3(Z) max3(Z)])
    daspect([1 1 .04])
    
    %FIND 90% 4 DIMENSIONAL CONFIDENCE CONTOUR --------------------------------
    isovalue = fcndsearch(Z,input.CEValue/100);
    %enclosedVol = np*input.google.maps.pixelspacingkm^2*drp;
    x = r; y = c; v = Z;
    %v = smooth3(v,'box',1);
    p1 = patch(isosurface(x,y,z,v,isovalue));
    set(p1,'FaceColor',[.6 .6 .6],'EdgeColor','none','FaceAlpha',.8)
    %reducepatch(p1, .8)
    lighting phong
    material shiny
    light('Position',[0 0 +100]); light('Position',[-500 0 1]); light('Position',[0 -500 1]); light('Position',[500 0 1]); light('Position',[0 500 1]);
    isonormals(x,y,z,v,p1) %smooths lighting
    p2 = patch(isocaps(x,y,z,v,isovalue)); set(p2,'EdgeColor','none','FaceColor','interp','SpecularColorReflectance',0,'SpecularStrength',.3);
    set(gca,'YTick',-90:90:90,'XTick',-180:90:180);
    
    %sc = fcnCC2SC(d1.z.udxecef*d1.DCM_NED2ECEF); hold on
    %plot3(sc(:,2),sc(:,3),d1.z.e,'g.','MarkerSize',3); %measurements
    
    %DEFINE CUBIC INTERP POINTS (DENSE GRID) ----------------------------------
    [rm,cm] = meshgrid(r,c);
    L2 = sum(Z,3);
    r2 = linspace(max(r), min(r), 2*numel(r));
    c2 = linspace(min(c), max(c), 2*numel(c));
    [rm2,cm2] = meshgrid(r2,c2);
    L3 = qinterp2(rm, cm, L2, rm2, cm2, 2);
    
    %FIGURE2
    sca(hs2(k))
    pcolor(cm2,rm2,L3); shading flat; axis equal tight;
    %plot(sc(:,3),sc(:,2),'.','Color','g','MarkerSize',3); %measurements
    plot(scCont(:,3), scCont(:,2), 'w.','MarkerSize',3);
    set(gca,'YTick',-90:90:90,'XTick',-180:90:180); caxis([min3(L3) max3(L3)+1E-6])
    title(titlecells{k},'Units','Normalized','Position',[.5 .995])
    xlabel('az (deg)','Units','Normalized','Position',[.5 -.16])
    ylabel('el (deg)','Units','Normalized','Position',[-.06 .5])
    
    if any(k==[2 3 4])
        sca(hs3)
        x=rm2(1,1:end);
        plot(x,nansum(L3).*cosd(x),'LineWidth',2,'DisplayName',titlecells{k})
    end
    
end
sca(hs3); xyzlabel('Nadir Angle (deg)','Relative Flux'); legend show; fcntight


toc
end

function addBorder(input, flags, pos0, DCM_ECEF2NED)
ex = input.google.maps.extent;
latv = linspace(ex(1),ex(2),50)';
lngv = linspace(ex(3),ex(4),50)';
latvr = linspace(ex(2),ex(1),50)';
lngvr = linspace(ex(4),ex(3),50)';
ov = ones(50,1);
lla = [     latv,       ex(3)*ov
    ex(2)*ov,   lngv
    latvr,       ex(4)*ov
    ex(1)*ov,   lngvr];
lla(:,3) = fcnGetAltitude(input, flags, lla(:,1), lla(:,2));
ecef = lla2ecef(lla);
ned = (ecef-ones(200,1)*pos0) * DCM_ECEF2NED';
plot3(ned(:,1),ned(:,2),ned(:,3),'-','Color',[.7 .7 .7])
end

function sc = worldContour(input, d1)
ts = 20; %tile spacing
r = (60*180+1):-ts:1;
c = 1:ts:(60*360+1);

cz = double(input.ETOPO.ETOPO1_Ice_g(r,c));
r = 1:ts:(60*180+1); %swap lat directions
clats = (r-1)/60-90;
clngs = (c-1)/60-180;
c = contourc(clngs,clats,cz,[0 0]); c=c(:,c(1,:)~=0)';

ecef = lla2ecef([c(:,2) c(:,1) c(:,1)*0]);
[~, dx] = fcnrange(d1.positionECEF, ecef);
sc = fcnCC2SC(dx*d1.DCM_NED2ECEF);
end

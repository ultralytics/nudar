function []= fcnPlotMantle(input, table)
ss = get(0,'ScreenSize');
set(figure,'Position',ss)

%PLOT ELEMENT DENSITIES
subplot(231)
r = (3000:1:6800)';
rho = compute_geoneutrinos_mulliss2(r);
plot(r,rho(:,1)*4*pi,'r'); hold on
plot(r,rho(:,2)*4*pi,'g')
plot(r,rho(:,3)*4*pi,'b')
legend('Uranium 238','Thorium 232','Potassium 40'); axis tight
xlabel('Earth Radius From Center (km)'); ylabel('antineutrinos/cm^3/s'); title('Mantle Flux')
fcncontextmenuexpand(gca)

%PLOT PDF
st = table.mantle.uranium;
st.pdfThetaRange = st.pdfThetaRange*st.n*st.dr*st.dtheta;
st.pdfThetaEnergy = st.pdfThetaEnergy*st.n*st.dr*st.de;
climr = [0 max3(st.pdfThetaRange)];
clime = [0 max3(st.pdfThetaEnergy)];

subplot(232)
h1=pcolor(st.theta,st.r,st.pdfThetaRange'); hold on
xlabel('Theta Off Detector Nadir (deg)'); ylabel('Range from Detector (km)'); title(sprintf('Mantle Uranium PDF (%.3f/yr/1E32p)',st.n*1E32))
set(get(gca,'child'),'FaceColor','flat','EdgeColor','none');
plot(st.theta(1),st.r(1),'.b','MarkerSize',40); %detector dot!
axis tight
view(0,-90); caxis(climr)
fcncontextmenuexpand(h1)

subplot(235)
h1=pcolor(st.theta,st.e,st.pdfThetaEnergy'); shading flat; hold on
xlabel('Theta Off Detector Nadir (deg)'); ylabel('Energy (MeV)'); title('Mantle Uranium PDF')
axis tight
caxis(clime)
fcncontextmenuexpand(h1)

st1 = st;
st = table.mantle.thorium;
st.pdfThetaRange = st.pdfThetaRange*st.n*st.dr*st.dtheta;
st.pdfThetaEnergy = st.pdfThetaEnergy*st.n*st.dr*st.de;
subplot(233)
h1=pcolor(st.theta,st.r,st.pdfThetaRange'); hold on
xlabel('Theta Off Detector Nadir (deg)'); ylabel('Range from Detector (km)'); title(sprintf('Mantle Thorium PDF (%.3f/yr/1E32p)',st.n*1E32))
set(get(gca,'child'),'FaceColor','flat','EdgeColor','none');
plot(st.theta(1),st.r(1),'.b','MarkerSize',40); %detector dot!
axis tight
view(0,-90); caxis(climr)
fcncontextmenuexpand(h1)

subplot(236)
epdf = st1.pdfThetaEnergy*0; [r,c]=size(st.pdfThetaEnergy); epdf(1:r,1:c)=st.pdfThetaEnergy;
h1=pcolor(st1.theta,st1.e,epdf'); shading flat; hold on
xlabel('Theta Off Detector Nadir (deg)'); ylabel('Energy (MeV)'); title('Mantle Thorium PDF')
axis tight
caxis(clime)
fcncontextmenuexpand(h1)
drawnow

%PLOT RADIUS RINGS
subplot(234)
np = 1000;
lngs = [90*ones(np/2,1); -90*ones(np/2,1)];
lats = [linspace(90,-90,np/2)'; linspace(-90,90,np/2)'];

wgs84 = lla2ecef([lats lngs zeros(np,1)]);
sphere = lla2ecef([lats lngs zeros(np,1)],0);
uppermantle = lla2ecef([lats lngs -20*ones(np,1)*1E3],0); %20km below sphere
lowermantle = lla2ecef([lats lngs -3131*ones(np,1)*1E3],0); %3131km below sphere

plot3(wgs84(:,1),wgs84(:,2),wgs84(:,3),'g'); hold on
plot3(sphere(:,1),sphere(:,2),sphere(:,3), 'b');
plot3(uppermantle(:,1),uppermantle(:,2),uppermantle(:,3), 'r');
plot3(lowermantle(:,1),lowermantle(:,2),lowermantle(:,3), 'r');
fcncontextmenuexpand(gca)

%SAMPLE PDF IN 3D WORLD ---------------------------------------------------
d2r = pi/180;
LLA = [90 0 0];
DCM_NED2ECEF = fcnLLA2DCM_NED2ECEF(LLA*d2r);
p1 = lla2ecef(LLA);

ne = 5000; %9 events per kiloton per year
ztruth.e = zeros(ne,1);
ztruth.uvec = zeros(ne,3);
ztruth.id = zeros(ne,1);
ztruth.p2ecef = zeros(ne,3);

typeStrings = {'thorium','potassium','uranium'};
net = 0;
for type=1
    st = eval(['table.mantle.' typeStrings{type} ]); %struct

    net = net+ne;
    v1 = (net-ne+1):(net);
    if ne>0
        %GET EVENT RANGES AND ANGLES (2D CDF)
        cdf = st.cdfmarginalRange;
        cdfx = st.r;
        r = fcnrandcdf(cdf, cdfx, ne);
        
        %GET EVENT DAYS       
        rid = ceil(r/st.dr);
        cdfx = st.theta;
        cdftheta = cumsum(st.pdfThetaRange,1)*st.dtheta;
        for i = 1:ne
            %GET EVENT RECONSTRUCTION VECTORS
            cdfy = cdftheta(:,rid(i));
            el1 = -90 + fcnrandcdf(cdfy, cdfx, 1); %elevation above horizon plane (should be negative)
            az1 = (rand*2-1)*180; %az angle
                        
            DCM_B2W     = fcnRPY2DCM_B2W([0 el1 az1]*d2r);
            vecNED      = DCM_B2W*[1; 0; 0];
            vecECEF     = DCM_NED2ECEF*vecNED;
            
            p2NED       = DCM_B2W*[r(i); 0; 0];
            p2ECEF      = DCM_NED2ECEF*p2NED + p1';
            
            ztruth.uvec(v1(i),:) = vecECEF;
            ztruth.p2ecef(v1(i),:) = p2ECEF';
            ztruth.id(v1(i)) = -type;
        end
    end
end
hold on; plot3(p1(1),p1(2),p1(3),'.b','MarkerSize',30)

p2 = ztruth.p2ecef;
% v1 = find(p2(:,1)<100 & p2(:,1)>-100);
% p2 = p2(v1,:);
hold on; plot3(p2(:,1),p2(:,2),p2(:,3),'.b','MarkerSize',1)
xlabel('ECEF X (km)'); ylabel('ECEF Y (km)'); zlabel('ECEF Z (km)');
title('Mantle Model MC Sampling')
view(-80,10); axis tight; box on; axis vis3d

%spin
% elvec = -80+logspace(0,-3,100)*180;
% for el = elvec
%     view(el,10)
%     drawnow
% end

legend('WGS84 Ellipsoid R=6356.8km to 6378.1km','Sphere R=6378km','Upper Mantle Boundary R=6291km','Lower Mantle Boundary R=3480km','Detector','Mantle Source Points (MC)','Location','SouthEast')
end



function ecef = lla2ecef(lla,f)
%lla = [lat (deg), lng (deg), altitude (m)]
%ecef = km

d2r = pi/180;
if nargin==1
    f = 1/298.257223563; %define WGS84 flattening
end
R = 6378.1370; %WGS84 equatorial radius (km)

lat = lla(:,1)*d2r;
lng = lla(:,2)*d2r;
alt = lla(:,3)/1000;

lambda = atan((1-f)^2*tan(lat)); %mean sea level at lat

slambda = sin(lambda);
slat = sin(lat);
slng = sin(lng);

clambda = cos(lambda);
clat = cos(lat);
clng = cos(lng);

r = sqrt( R^2./(1+(1/(1-f)^2-1)*slambda.^2) ); %radius at surface point
k1 = r.*clambda+alt.*clat;

ecef = [k1.*clng,  k1.*slng,  r.*slambda+alt.*slat];
end
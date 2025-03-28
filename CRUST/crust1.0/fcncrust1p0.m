% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

function crust = fcncrust1p0(input,table)
layerNames = {'1. Water';'2. Ice';'3. Upper Sediment';'4. Middle Sediment';'5. Lower Sediment';'6. Upper Crust';'7. Middle Crust';'8. Lower Crust (Mohorovicic Discontinuity)';'9. Upper Mantle'};
s = [360,180,9];

x = importfile('crust1.rho');   x = reshape(x,s);  density = x; %(g/cm^3)
x = importfile('crust1.vp');    x = reshape(x,s);  vp = x; %(km/s)
x = importfile('crust1.vs');    x = reshape(x,s);  vs = x; %(km/s)
x = importfile('crust1.bnds');  x = reshape(x,s);  x(:,:,1:8) = x(:,:,1:8)-x(:,:,2:9);  thickness = x; %(km)

CT = fcnloadtextfile('CNtype1-1.txt',500,false);  CT = CT.xs;%crust type

% %OLD ABUNDANCE TABLE Mantovani et al 2004 -------------------------------
% %   uranium      thorium     potassium
% abundanceTable = [   ...
%    .0032E-6            0       0.04E-2           %1. water  -Mantovani et al. 2004
%    .0032E-6            0       0.04E-2           %2. ice  -Mantovani et al. 2004
%     1.68E-6       6.9E-6        1.7E-2           %3. upper sediment
%     1.68E-6       6.9E-6        1.7E-2           %4. middle sediment
%     1.68E-6       6.9E-6        1.7E-2           %5. lower sediment
%      2.5E-6       9.8E-6       2.57E-2           %6. upper crust
%      1.6E-6       6.1E-6       1.67E-2           %7. middle crust
%     0.62E-6       3.7E-6       0.72E-2           %8. lower crust (moho)
%    .0065E-6    0.0173E-6     0.0078E-2     ];    %9. upper mantle

%ABUNDANCE TABLE Huang et al 2013 http://arxiv.org/abs/1301.0365 ---------
%   uranium      thorium     potassium
abundancesCC = [   ... %Continental Crust (CC)
   .0032E-6            0       0.04E-2           %1. water  -Mantovani et al. 2004
   .0032E-6            0       0.04E-2           %2. ice  -Mantovani et al. 2004
    1.73E-6      8.10E-6       1.83E-2           %3. upper sediment
    1.73E-6      8.10E-6       1.83E-2           %4. middle sediment
    1.73E-6      8.10E-6       1.83E-2           %5. lower sediment
    2.70E-6      10.5E-6       2.32E-2           %6. upper crust
    0.97E-6      4.86E-6       1.52E-2           %7. middle crust
    0.16E-6      0.96E-6       0.65E-2           %8. lower crust (moho)
   0.030E-6     0.150E-6      0.032E-2     ];    %9. upper mantle -Huang's 'LM' Lithospheric Mantle under CC

abundancesOC = [   ... %Oceanic Crust (OC)
   .0032E-6            0       0.04E-2           %1. water  -Mantovani et al. 2004
   .0032E-6            0       0.04E-2           %2. ice  -Mantovani et al. 2004
    1.73E-6      8.10E-6       1.83E-2           %3. upper sediment
    1.73E-6      8.10E-6       1.83E-2           %4. middle sediment
    1.73E-6      8.10E-6       1.83E-2           %5. lower sediment
    0.07E-6      0.21E-6       0.07E-2           %6. upper crust
    0.07E-6      0.21E-6       0.07E-2           %7. middle crust
    0.07E-6      0.21E-6       0.07E-2           %8. lower crust (moho)
%  0.008E-6     0.022E-6      0.015E-2     ];    %9. upper mantle -Huang's 'DM' Depleted Mantle
  0.0109E-6    0.0220E-6      0.0151E-2     ];    %Steve Dye's HPE homogeneous mantle 4/10/2015


%ISOTOPE MASSES -----------------------------------------------------------
amu=1.660538782E-24; %g
%                   [u238           th232       k40         ]
isotope_abundance = [0.992745       1.0         0.000117    ];
lifetime =          [6.446          20.212      1.8005      ] * (1E9*365.25*24*60*60); %Gyr to seconds (lifetime = halflife/log(2))
multiplicity =      [6              4           0.893       ]; %nuebars/decay
mass =              [238.0507826    232.0381    39.96399848 ]*amu;


zm = zeros(s); V=zm; M=zm; D=zm; L=zm; T=zm; A=zm; P=zm; TEMP=zm; F=zeros([s 3]); E=F; OC=zm;
latv =   89.5 : -1 : -89.5;
lngv = -179.5 :  1 : 179.5;
[latm, lngm] = meshgrid(latv,lngv);
altm = reshape(fcntilealtitude(input,latm(:),lngm(:)),s(1:2));
dl = .5; %deg
for i = 1:360
    lng = lngv(i);
    for j=1:180
        lat = latv(j);
        
        %get wgs84 radius
        rtoptile1 = norm( lla2ecef([lat lng altm(i,j)]) ); %top tile radius from center of earth (km)
        solidAnglefraction = (sind(lat+dl)-sind(lat-dl)).*((lng+dl) - (lng-dl)) *d2r/(4*pi); %steradians
        tilearea = 4*pi*rtoptile1^2 * solidAnglefraction; %(km^2) of upper tile
        
        %OCflag = false;
        OCflag = any(strcmp(CT{j,i},{'A0','A1','B-','V1','Y3'}));
        
        r2 = rtoptile1;
        vol2 = 4/3*pi*r2^3; %larger volume
        for k=1:9
            thicknessi = thickness(i,j,k);  if thicknessi==0; continue; end  %(km)
            densityi   = density(i,j,k); %g/cm^3
            if k==1 %if water
                %OCflag = thicknessi>1.0; %OC = >1km of water
            elseif k==9
                thicknessi = max(r2-table.mantle.r2, 0); %km to join mantle
                densityi = 3.37; %(g/cm^3) LM density from Huang (really from PREM)
            end
            
            r1 = r2 - thicknessi; %smaller radius
            vol1 = 4/3*pi*r1^3; %smaller volume
            volume = (vol2-vol1).*solidAnglefraction*1E15; %cm^3
            rmean = (r1+r2)/2; %km
            r2 = r1;
            vol2 = vol1;
            
            L(i,j,k) = k; %layer number
            V(i,j,k) = volume; %cm^3
            M(i,j,k) = volume*densityi; %mass (g)
            D(i,j,k) = densityi; %density (g/cm^3)
            T(i,j,k) = thicknessi; %(km)
            A(i,j,k) = altm(i,j)-(rtoptile1-rmean)*1000; %altitude (m)
            
            P(i,j,k) = (densityi*1000)*(thicknessi*1000)*9.81 * (1E-6); %pressure (MPa) = kg/m^3 * m * m/s^2 *1E-6
            TEMP(i,j,k) = 10 + 71.6 .* (1-exp(A(i,j,k)/1000/10)) + 10.7 .* -A(i,j,k)/1000;
            
            %NEUTRINO FLUXES ----------------------------------------------------------
            if OCflag
                OC(i,j,k) = 1;
                abundance=abundancesOC(k,:).*isotope_abundance; %Compute total abundance
            else
                abundance=abundancesCC(k,:).*isotope_abundance; %Compute total abundance
            end
            isotope_density=abundance*densityi; %Compute total density for radioactive species
            fluxdensity = (multiplicity.*isotope_density)./(lifetime.*mass);  %(#/cm^3/s) Compute anti-neutrino fluxes
            F(i,j,k,:) = fluxdensity * volume;%(#/s/tile) (emanating in all directions). Divide by 4pi to get #/s/sterradian
            E(i,j,k,:) = fluxdensity * (volume/tilearea); %fluxdensity * (volume / tilearea); %(#/s/km^2) from all isotopes
        end
    end
end
P = cumsum(P,3)-P/2;
vp(T==0)=0;
[wm, wsu, wsl, mu] = runAGM2016Fit(vp,M,P,TEMP,OC,latm,lngm);  
vCorr = (TEMP-25)*-4E-4 + (P-600)*2E-4;



layerNames = {'water';'ice';'upper sediment';'middle sediment';'lower sediment';'upper crust';'middle crust';'lower crust';'upper mantle'};
plotnames = {'altitude','density','thickness','tile mass','luminosity','luminosity','vp','vs','vp/vs','Oceanic Crust','Pressure','Temperature','P and T Corrections'};
plotunits = {'km','g/cm^3','km','g','\nu/s/tile','\nu/s/km^2','km/s','km/s','','','Mpa','^oC','km/s'};
plotdata = {A/1000,D,T,M,sum(F,4),sum(E,4),vp,vs,vp./vs,OC,P,TEMP,vCorr};
for i=[7 11 12 13]
    plotcrust1p0(layerNames,latm,lngm,plotdata{i},plotnames{i},plotunits{i});
end
''

% a=squeeze( sum(sum(sum(permute(F,[1 2 4 3]),1),2),3) );
% A=a/510E6; %earth area km^2
% f=squeeze( sum(mean(mean(permute(E,[1 2 4 3]),1),2),3) );
% for i=1:9
%    fprintf('%-40s %10.2g %10.2g %10.2g\n',layerNames{i},a(i),A(i),f(i)) 
% end

% R = E(:,:,:,2)./E(:,:,:,1); %Th/U ratio
% U = E(:,:,:,1); U(isnan(U))=0;
% Th = E(:,:,:,2); Th(isnan(Th))=0;
% Rall = sum(Th,3)./sum(U,3);
% 
% plotcrust(layerNames,latm,lngm,R,repmat(Rall,[1 1 9]),'Th/U Abundance Density Ratio','luminosity (\nu/s/km^2)')
% h=findobj(gcf,'type','axes'); for i=1:8; caxis(h(i),[0 6]); end

LAT=repmat(latm,[1 1 9]);  LNG=repmat(lngm,[1 1 9]);
LLA = [LAT(:) LNG(:) A(:)];
ECEF = lla2ecef(LLA);
F = reshape(F,[prod(s) 3]);

lat=latm; %#ok<*NASGU>
lng=lngm;
i = find(V(:)>0); %find all layers with crust thicker than 0km
all.n = numel(i);
all.thickness = T(i);
all.volume = V(i);
all.density = D(i);
all.mass = M(i);
all.flux = F(i,:);
all.lla = LLA(i,:);
all.ecef = ECEF(i,:);
all.layer = L(i);
all.OCflag = OC(i);

filename = ([input.directory '/MATfiles/crust1p0.mat']);
fprintf('Saving new crust mat file ''%s''... ',filename)
%save('-v6',filename,'all','lat','lng','layerNames')
fprintf('Done.\n')

if nargout>0
    crust.all = all;
    crust.lat = latm;
    crust.lng = lngm;
    crust.layerNames = layerNames;
end
end


function altitude = fcntilealtitude(input,lat,lng) %FIND MEAN TOP ALTITUDE FOR THIS TILE
altetopo = etopo1(lat,lng,input.ETOPO);
altegm = egm1(lat,lng,input.EGM);
altitude = max(altetopo,altegm);
end


% a=table.crust.all;
% [2.32E-2  1.52E-2 0.65E-2]*...
% [sum3(a.mass(a.layer==6 & a.OCflag)), sum3(a.mass(a.layer==7 & a.OCflag)), sum3(a.mass(a.layer==8 & a.OCflag))]'./sum3(a.mass(a.layer>=6 & a.layer<=8 & a.OCflag))
% 
% [2.32E-2  1.52E-2 0.65E-2]*...
% [sum3(a.mass(a.layer==6 & ~a.OCflag)), sum3(a.mass(a.layer==7 & ~a.OCflag)), sum3(a.mass(a.layer==8 & ~a.OCflag))]'./sum3(a.mass(a.layer>=6 & a.layer<=8 & ~a.OCflag))


function bnds = importfile(filename, startRow, endRow)
%IMPORTFILE Import numeric data from a text file as a matrix.
%   BNDS = IMPORTFILE(FILENAME) Reads data from text file FILENAME for the
%   default selection.
%   BNDS = IMPORTFILE(FILENAME, STARTROW, ENDROW) Reads data from rows
%   STARTROW through ENDROW of text file FILENAME.
% Example:
%   bnds = importfile('crust1.bnds', 1, 64800);
if nargin<=2
    startRow = 1;
    endRow = inf;
end
formatSpec = '%7f%7f%7f%7f%7f%7f%7f%7f%f%[^\n\r]';
fileID = fopen(filename,'r');
dataArray = textscan(fileID, formatSpec, endRow(1)-startRow(1)+1, 'Delimiter', '', 'WhiteSpace', '', 'EmptyValue' ,NaN,'HeaderLines', startRow(1)-1, 'ReturnOnError', false);
for block=2:length(startRow)
    frewind(fileID);
    dataArrayBlock = textscan(fileID, formatSpec, endRow(block)-startRow(block)+1, 'Delimiter', '', 'WhiteSpace', '', 'EmptyValue' ,NaN,'HeaderLines', startRow(block)-1, 'ReturnOnError', false);
    for col=1:length(dataArray)
        dataArray{col} = [dataArray{col};dataArrayBlock{col}];
    end
end
fclose(fileID);
bnds = [dataArray{1:end-1}];
end
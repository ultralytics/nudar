function hOut = fcnPlotElevations(input)
maps = input.google.maps;

%pop out plot
x = reshape(maps.ECEF(:,1),input.nxy,input.nxy);
y = reshape(maps.ECEF(:,2),input.nxy,input.nxy);
z = reshape(maps.ECEF(:,3),input.nxy,input.nxy);
c = reshape(maps.LLA(:,3),input.nxy,input.nxy);

h1 = figure;
set(h1,'Position',[830 50 800 800]); surf(x,y,z,c,'EdgeColor','none');
xlabel('ECEF X (km)'); ylabel('ECEF Y (km)'); zlabel('ECEF Z (km)'); title('ETOPO1 Ice Elevation (Meters in ECEF View)')
axis tight equal vis3d; alpha(1); box on; grid off; colorbar('East');

x = reshape(maps.LLA(:,1),input.nxy,input.nxy);
y = reshape(maps.LLA(:,2),input.nxy,input.nxy);
z = reshape(maps.LLA(:,3),input.nxy,input.nxy);
c = reshape(maps.LLA(:,3),input.nxy,input.nxy);

h2 = figure;
set(h2,'Position',[10 50 800 800]); surfc(x,y,z,c,'EdgeColor','none');
xlabel('Latitude (deg)'); ylabel('longitude(deg)'); zlabel('Elevation (m)'); title('ETOPO1 Ice Elevation (Meters in LLA View)')
axis tight vis3d; alpha(1); box on; grid off; colorbar('East'); view(70,70); shading interp
set(gca,'XDir','Reverse')

hOut = [h1 h2];
end


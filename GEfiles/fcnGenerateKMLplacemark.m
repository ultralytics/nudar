function [] = fcnGenerateKMLplacemark(input, lla, descriptor, kmlfname, color)
% yellow = '#FF00FFFF';
% blue = '#FFFF0000';
% green = '#FF00FF00';
% red = '#FF0000FF';

dir = [input.directory '/GEfiles/KML/'];

fid = fopen([dir kmlfname],'w');
fprintf(fid,'<?xml version="1.0" encoding="UTF-8"?>\n');
fprintf(fid,'<kml xmlns="http://www.opengis.net/kml/2.2">\n');fprintf(fid,'<Document>');
fprintf(fid,['	<name>' descriptor '</name>\n']);
fprintf(fid,'   <Style id="sn_arrow">\n');
fprintf(fid,'		<IconStyle>\n');
fprintf(fid,['			<color>' color '</color>\n']);
fprintf(fid,'			<scale>1.2</scale>\n');
fprintf(fid,'			<Icon>\n');
fprintf(fid,'				<href>http://maps.google.com/mapfiles/kml/shapes/arrow.png</href>\n');
fprintf(fid,'			</Icon>\n');
fprintf(fid,'			<hotSpot x="32" y="1" xunits="pixels" yunits="pixels"/>\n');
fprintf(fid,'		</IconStyle>\n');
fprintf(fid,'		<ListStyle>\n');
fprintf(fid,'		</ListStyle>\n');
fprintf(fid,'	</Style>\n');
fprintf(fid,'	<StyleMap id="msn_arrow">\n');
fprintf(fid,'		<Pair>\n');
fprintf(fid,'			<key>normal</key>\n');
fprintf(fid,'			<styleUrl>#sn_arrow</styleUrl>\n');
fprintf(fid,'		</Pair>\n');
fprintf(fid,'		<Pair>\n');
fprintf(fid,'			<key>highlight</key>\n');
fprintf(fid,'			<styleUrl>#sh_arrow</styleUrl>\n');
fprintf(fid,'		</Pair>\n');
fprintf(fid,'	</StyleMap>\n');
fprintf(fid,'	<Style id="sh_arrow">\n');
fprintf(fid,'		<IconStyle>\n');
fprintf(fid,['			<color>' color '</color>\n']);
fprintf(fid,'			<scale>1.4</scale>\n');
fprintf(fid,'			<Icon>\n');
fprintf(fid,'				<href>http://maps.google.com/mapfiles/kml/shapes/arrow.png</href>\n');
fprintf(fid,'			</Icon>\n');
fprintf(fid,'			<hotSpot x="32" y="1" xunits="pixels" yunits="pixels"/>\n');
fprintf(fid,'		</IconStyle>\n');
fprintf(fid,'		<ListStyle>\n');
fprintf(fid,'		</ListStyle>\n');
fprintf(fid,'	</Style>\n');
fprintf(fid,'	<Placemark>\n');
fprintf(fid,['		<name>' descriptor '</name>\n']);
fprintf(fid,'		<LookAt>\n');
fprintf(fid,['			<longitude>' sprintf('%f',lla(2)) '</longitude>\n']);
fprintf(fid,['			<latitude>' sprintf('%f',lla(1)) '</latitude>\n']);
fprintf(fid,'			<altitude>0</altitude>\n');
fprintf(fid,'			<heading>2</heading>\n');
fprintf(fid,'			<tilt>30</tilt>\n');
fprintf(fid,'			<range>2000</range>\n');
fprintf(fid,'			<altitudeMode>relativeToGround</altitudeMode>\n');
fprintf(fid,'			<gx:altitudeMode>relativeToSeaFloor</gx:altitudeMode>\n');
fprintf(fid,'		</LookAt>\n');
fprintf(fid,'		<styleUrl>#msn_arrow</styleUrl>\n');
fprintf(fid,'		<Point>\n');
fprintf(fid,['			<coordinates>' sprintf('%f,%f,0',lla(2),lla(1)) '</coordinates>\n']);
fprintf(fid,'		</Point>\n');
fprintf(fid,'	</Placemark>\n');
fprintf(fid,'</Document>\n');
fprintf(fid,'</kml>\n');
fclose(fid);

winopen([dir kmlfname])
end



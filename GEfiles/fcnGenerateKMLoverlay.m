function [] = fcnGenerateKMLoverlay(input, kmlfname, picfname, kmlname, extent)
%extent = [min(lat) max(lat) min(lng) max(lng)]

fprintf('Generating ''%s'' in folder ''%s''...',kmlfname,[input.directory filesep 'GEfiles' filesep 'KML' filesep]); tstart=clock;
dir = [input.directory filesep 'GEfiles' filesep 'KML' filesep];

fid = fopen([dir kmlfname],'w');
fprintf(fid,'<?xml version="1.0" encoding="UTF-8"?>\n');
fprintf(fid,'<kml xmlns="http://www.opengis.net/kml/2.2">\n');
fprintf(fid,'<GroundOverlay>\n');
fprintf(fid,['	<name>' kmlname '</name>\n']);
fprintf(fid,'	<color>bdffffff</color>\n');
fprintf(fid,'	<Icon>\n');
fprintf(fid,['		<href>' dir filesep picfname '</href>\n']);
fprintf(fid,'       <refreshMode>onInterval</refreshMode>');
fprintf(fid,'       <refreshInterval>1</refreshInterval>');
fprintf(fid,'		<viewBoundScale>0.75</viewBoundScale>\n');
fprintf(fid,'	</Icon>\n');
fprintf(fid,'	<LatLonBox>\n');
fprintf(fid,'		<north>%.6f</north>\n',extent(2));
fprintf(fid,'		<south>%.6f</south>\n',extent(1));
fprintf(fid,'		<east>%.6f</east>\n',extent(3));
fprintf(fid,'		<west>%.6f</west>\n',extent(4));
%                <rotation>0</rotation>
fprintf(fid,'	</LatLonBox>\n');
fprintf(fid,'</GroundOverlay>\n');
fprintf(fid,'</kml>\n');
fclose(fid);

fprintf('   Done. (%.1fs)\n',etime(clock,tstart))
end


% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

function [] = fcnGoogleEarth(input, handles, flags)
dir = [input.directory '/GEfiles/KML/'];
gm = input.google.maps;
if ispc; winopen([dir 'Screen Overlays.kml']); end

% %GENERATE GOOGLE EARTH OVERLAY --------------------------------------------    
X = reshape(gm.LLA(:,1),input.nxy,input.nxy);
Y = reshape(gm.LLA(:,2),input.nxy,input.nxy);
    

if ~isempty([handles.ML123 handles.ML3 handles.ML1 handles.ML2 handles.ML0])
    if ~isempty(handles.ML0)
        Z=get(handles.ML0(1),'Cdata');
    elseif ~isempty(handles.ML1)
        Z=get(handles.ML1(1),'Cdata');
    elseif ~isempty(handles.ML2)
        Z=get(handles.ML2(1),'Cdata');
    elseif ~isempty(handles.ML3)
        Z=get(handles.ML3(1),'Cdata');
    elseif ~isempty(handles.ML123)
        Z=get(handles.ML123(1),'Cdata');
    end
    
    picfname = 'Estimator Overlay.png';
    fcnGenerateKMLoverlayPNG(input, picfname, X, Y, Z, gm.extentML)
    fcnGenerateKMLoverlay(input,'Estimator Overlay.kml',picfname,'Estimator Overlay',gm.extent)
    if ispc; winopen([dir 'Estimator Overlay.kml']); end
elseif ~isempty(handles.CRLB)
    Z=get(handles.CRLB(1),'Cdata');
    picfname = 'CRLB Overlay.png';
    fcnGenerateKMLoverlayPNG(input, picfname, X, Y, Z, gm.extentML)
    fcnGenerateKMLoverlay(input,'CRLB Overlay.kml',picfname,'CRLB Overlay',gm.extent)
    if ispc; winopen([dir 'CRLB Overlay.kml']); end
else
    picfname = 'Current Overlay.png';
    Z = getframe(handles.GUI.axes1); Z=double(Z.cdata); %figure; imshow(Z);

    dmax = max(gm.extent(4)-gm.extent(3),gm.extent(2)-gm.extent(1)); %deg
    dx = dmax/2000; %space 500 pixels along the largest dimension
    
    xiv = gm.extent(2):-dx:gm.extent(1); %lat order is reversed because row order is reversed with imwrite
    yiv = gm.extent(3):dx:gm.extent(4);
    
    [xi,yi] = meshgrid(xiv, yiv);
    
    X = interp1(1:640, gm.latVec, linspace(640,1,size(Z,1)));
    Y = interp1(1:640, gm.lngVec, linspace(1,640,size(Z,2)));
    [X, Y] = meshgrid(X,Y);
    
    Zi = zeros(size(xi,2),size(xi,1),3);
    for i = 1:3
        z = Z(:,:,i)';
        zi = interp2(X,Y,z,xi,yi,'linear');
        Zi(:,:,i) = zi';
    end

    imwrite(uint8(Zi),colormap,[input.directory filesep 'GEfiles' filesep 'KML' filesep picfname],'png');
    fcnGenerateKMLoverlay(input,'Current Overlay.kml',picfname,'Current Overlay', input.google.maps.extent);
    if ispc; winopen([dir 'Current Overlay.kml']); end
end
fcnGenerateKMLcylinders(input, flags)
if ispc; winopen([dir 'cylinders.kml']); end



% %GENERATE GOOGLE EARTH CONTOUR --------------------------------------------
% kmlStr = ge_contour(X,Y,Z,'lineColor','FFFFFFFF','lineWidth',2,'lineValues',[10 20]);
% ge_output([dir 'contourTest.kml'],kmlStr);
% 
% winopen([dir 'Estimator Overlay.kml']);
% pause(.3)
% winopen([dir 'contourTest.kml']);

%Set Camera Location and Attitude
if ispc
    handle = actxserver ('googleearth.ApplicationGE');%  Create a COM server running Google Earth
    alt = 0;
    altMode = 2;
    range = 1500*1000;
    tilt = 30;
    heading = 2;
    speed = 1;
    
    %Set Camera Parameters on Google Earth
    pause(.1)
    handle.SetCameraParams(input.google.maps.lat,input.google.maps.lng,alt,altMode,range,tilt,heading,speed);
    delete(handle)
end
end

%Get Target Location at Center of Screen
%my_target = handle.GetPointOnTerrainFromScreenCoords(0,0);
% pause(1)
% %Set Focus Point
% new_target = handle.GetCamera(0);
% set(new_target, 'FocusPointLatitude', lat);
% set(new_target, 'FocusPointLongitude', lng);
% set(new_target, 'FocusPointAltitude', 0); %meters
% set(new_target, 'FocusPointAltitudeMode', 2);
% set(new_target, 'Range', 1000*1000); %meters
% set(new_target, 'Tilt', 40);
% set(new_target, 'Azimuth', 0);
% handle.SetCamera(new_target,1);








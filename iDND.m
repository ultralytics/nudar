%INITIALIZATION FUNCTIONS -------------------------------------------------
function varargout = iDND(varargin)
% IDND M-file for iDND.fig
%      IDND, by itself, creates a new IDND or raises the existing
%      singleton*.
%
%      H = IDND returns the handle to a new IDND or the handle to
%      the existing singleton*.
%
%      IDND('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in IDND.M with the given input arguments.
%
%      IDND('Property','Value',...) creates a new IDND or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before iDND_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to iDND_OpeningFcn via varargin.
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @iDND_OpeningFcn, ...
    'gui_OutputFcn',  @iDND_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
% --- Executes just before iDND is made visible.
function iDND_OpeningFcn(hObject, eventdata, handles, varargin)
disableButtons(handles)
fprintf('Opening AntiNeutrino Geospatial Simulation, Please Wait...')
handles.output = hObject;
guidata(hObject, handles);
disableButtons(handles);
pushbuttonReset_Callback([],[],handles)
function varargout = iDND_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% Get default command line output from handles structure
varargout{1} = handles.output;
%fprintf('AntiNeutrino Source Simulation Successfully Opened.\n')

function figure1_CloseRequestFcn(hObject, eventdata, handles)
evalin('base','delete(get(0,''Children'')); clear')
fprintf('World Model Closed.\n');

%FILE MENU FUNCTIONS ------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
function OpenMenuItem_Callback(hObject, eventdata, h)
evalin('base','cd(input.directory)')
[file, path] = uigetfile([cd '/SAVED/*.mat']);
disableButtons(h)
if ~isequal(file, 0)
    evalin('base',['[d, input, handles, flags]=fcnopenfile(''' [path file] ''', table, stable, input);'])
    %popupmenuDetectorMass_Callback(hObject, eventdata, h)
end
enableButtons(h)
function SaveMenuItem_Callback(hObject, eventdata, h)
disableButtons(h)
[file, path] = uiputfile([cd '/SAVED/*.mat']);
if ~isequal(file, 0)
    evalin('base',['fcnsavefile(''' [path file] ''',d,input,handles,flags);'])
end
enableButtons(h)


%CREATE GUI FUNCTIONS -----------------------------------------------------
function popupmenuConfidencePercent_CreateFcn(hObject, eventdata, handles)
function popupmenuDetectorMass_CreateFcn(hObject, eventdata, handles)
evalin('base',['input.di=' num2str(get(hObject, 'Value')) ';']);
function listboxCriteria_CreateFcn(hObject, eventdata, h)
evalin('base',['input.ci=' num2str(get(hObject, 'Value')) ';']);
function editReactorPower_CreateFcn(hObject, eventdata, handles)
function editPriorRP1_CreateFcn(hObject, eventdata, handles)
str =  get(hObject, 'String');
evalin('base',['input.priors.rp1=' str '; input.rp1=' str ';'])
function editPriorRP2_CreateFcn(hObject, eventdata, handles)
str =  get(hObject, 'String');
evalin('base',['input.priors.rp2=' str '; input.rp2=' str ';'])
function editMCrunCount_CreateFcn(hObject, eventdata, handles)
function editReactorPowerMLEIG_CreateFcn(hObject, eventdata, handles)


%CALLBACK FUNCTIONS -------------------------------------------------------
function pushbuttonReset_Callback(hObject, eventdata, h)
disableButtons(h)
sca(h.axes1); cla
evalin('base','clc; clear')

fh = findall(0,'Type','figure'); %figure handles
v1 = fh~=h.figure1;
close(fh(v1))

hold(h.axes1,'on');
view(h.axes1,[90 -90]);
set(h.checkbox4,'Value',0)
set(h.checkbox6,'Value',0)
set(h.checkbox8,'Value',0)
set(h.checkbox9,'Value',0)
set(h.checkbox10,'Value',0)
set(h.checkbox12,'Value',0)
set(h.checkbox13,'Value',0)
set(h.checkbox14,'Value',0)
set(h.checkbox15,'Value',0)
set(h.textMCrun,'Visible','off')
set(h.togglebuttonMCmode,'Value',0)
set(h.uipanel4,'HighlightColor',[1 1 1]) %green MC stuff
set(h.uipanel4,'ForegroundColor',[0 0 0]) %green MC stuff
set(h.textMCrun,'String','0')
assignin('base','hgui',h); evalin('base','handles.GUI=hgui; clear hgui;')
evalin('base',['flags.status.EstMenuEnergyCut=' num2str( strcmp(get(h.EstMenuEnergyCut,'Checked'),'on')) ';'])

%UPDATE VARIABLES
evalin('base',['input.di=' num2str(get(h.popupmenuDetectorMass, 'Value')) ';']);
evalin('base',['input.ci=' num2str(get(h.listboxCriteria, 'Value')) ';']);
evalin('base',['input.dNoiseMultiplier=max(' get(h.editNoiseMultiplier,'String') ',0);'])
evalin('base','init')
updateVars(h)
evalin('base','updateDetectors;') %update all detectors
%DISPLAY MAP IF CHECKED
checkbox1_Callback([],[],h)
enableButtons(h)
function pushbuttonStartMC_Callback(hObject, eventdata, handles)
disableButtons(handles)
set(handles.uipanel4,'HighlightColor',[0 1 0]) %edge
set(handles.textMCrun,'ForegroundColor',[0 .9 0])
evalin('base','flags.status.MCmode=1; runMC')
enableButtons(handles)
function pushbuttonRun1MC_Callback(hObject, eventdata, handles)
disableButtons(handles)
AllFlagUpdate(handles)
evalin('base','updateDetectors; updatePlots')
enableButtons(handles)
function popupmenuDetectorMass_Callback(hObject, eventdata, h)
disableButtons(h)

AllFlagUpdate(h)
updateVars(h)
checkMCmode(h)
evalin('base','[input, table] = fcnosctables(input, table, flags); flags.update.crusttiles=1; updateDetectors;') %update all detectors
updateGoogleMap(h)
function listboxCriteria_Callback(hObject, eventdata, handles)
popupmenuDetectorMass_Callback(hObject, eventdata, handles)
function popupmenuConfidencePercent_Callback(hObject, eventdata, handles)
disableButtons(handles)
updateVars(handles)
evalin('base','updatePlots;')
enableButtons(handles)
function editNoiseMultiplier_Callback(hObject, eventdata, h)
updateVars(h)
pushbuttonRun1MC_Callback(hObject, eventdata, h)
function editReactorPower_Callback(hObject, eventdata, handles)
popupmenuDetectorMass_Callback([], [], handles)
function editPriorRP1_Callback(hObject, eventdata, handles)
disableButtons(handles)
updateVars(handles)
evalin('base','updatePlots')
enableButtons(handles)
function editPriorRP2_Callback(hObject, eventdata, handles)
disableButtons(handles)
updateVars(handles)
evalin('base','updatePlots')
enableButtons(handles)
function editMCrunCount_Callback(hObject, eventdata, h)
disableButtons(h)
evalin('base',['input.MCrunCount=' get(h.editMCrunCount, 'String') ';'])
enableButtons(h)
function editReactorPowerMLEIG_Callback(hObject, eventdata, handles)
disableButtons(handles)
updateVars(handles)
evalin('base','flags.update.ML1=1;flags.update.ML2=1;flags.update.ML4=1; updatePlots')
enableButtons(handles)
function togglebuttonMCmode_Callback(hObject, eventdata, handles)
disableButtons(handles)
toggledFlag = get(handles.togglebuttonMCmode,'Value');
if toggledFlag
    if evalin('base','exist(''dMCn'')') %if previous dMCn variable exists, set d=dMCn;
        set(handles.textMCrun,'Visible','on')%show how many MC runs existing results reflect
        set(handles.textMCrun,'ForegroundColor',[0 .9 0])%show how many MC runs existing results reflect
        set(handles.uipanel4,'HighlightColor',[0 1 0]) %edge
        drawnow
        evalin('base','d=dMCn; updatePlots')
    end
else
    set(handles.uipanel4,'HighlightColor',[1 1 1]) %edge
    evalin('base','updatePlots')
end
enableButtons(handles)
function pushbuttonGoogleEarth_Callback(hObject, eventdata, handles)
evalin('base','fcnGoogleEarth(input, handles, flags)');

%CHECKBOX CALLBACK FUNCTIONS ----------------------------------------------
function checkbox1_Callback(~, ~, h) %map
updateVars(h)
updateGoogleMap(h)
function checkbox4_Callback(hObject, eventdata, h) %ML0
disableButtons(h)
clearSurfaceCheckBoxes(hObject,h)
updateVars(h)
evalin('base','flags.update.ML0=1;')
evalin('base','updatePlots')
enableButtons(h)
function checkbox6_Callback(hObject, eventdata, h) %CRLB
disableButtons(h)
clearSurfaceCheckBoxes(hObject,h)
updateVars(h)
evalin('base','flags.update.CRLB=1;')
evalin('base','updatePlots')
enableButtons(h)
function checkbox10_Callback(hObject, eventdata, h) %Verbose Output
disableButtons(h)
AllFlagUpdate(h)
updateVars(h)
evalin('base','updatePlots')
enableButtons(h)
function checkbox12_Callback(hObject, eventdata, h) %ML1
disableButtons(h)
clearSurfaceCheckBoxes(hObject,h)
updateVars(h)
evalin('base','flags.update.ML1=1;')
evalin('base','updatePlots')
enableButtons(h)
function checkbox13_Callback(hObject, eventdata, h) %ML2
disableButtons(h)
clearSurfaceCheckBoxes(hObject,h)
updateVars(h)
evalin('base','flags.update.ML2=1;')
evalin('base','updatePlots')
enableButtons(h)
function checkbox14_Callback(hObject, eventdata, h) %ML4
disableButtons(h)
clearSurfaceCheckBoxes(hObject,h)
updateVars(h)
evalin('base','flags.update.ML4=1;')
evalin('base','updatePlots')
enableButtons(h)
function checkbox15_Callback(hObject, eventdata, h) %ML3
disableButtons(h)
clearSurfaceCheckBoxes(hObject,h)
updateVars(h)
evalin('base','flags.update.ML3=1;')
evalin('base','updatePlots')
enableButtons(h)

%MAP MOVEMENT FUNCTIONS ---------------------------------------------------
function radiobuttonReactor_Callback(hObject, eventdata, handles)
set(handles.radiobuttonExplosion,'value',0)
updateVars(handles)
pushbuttonReset_Callback(hObject, eventdata, handles)
evalin('base',['flags.explosion=0;'])
function radiobuttonExplosion_Callback(hObject, eventdata, handles)
set(handles.radiobuttonExplosion,'value',1)
updateVars(handles)
pushbuttonReset_Callback(hObject, eventdata, handles)
evalin('base',['flags.explosion=1;'])
function pushbuttonPanEast_Callback(hObject, eventdata, h)
evalin('base','input.google.maps.lng=input.google.maps.lng+10/input.google.maps.zoom;')
updateGoogleMap(h)
function pushbuttonPanWest_Callback(hObject, eventdata, h)
evalin('base','input.google.maps.lng=input.google.maps.lng-10/input.google.maps.zoom;')
updateGoogleMap(h)
function pushbuttonPanNorth_Callback(hObject, eventdata, h)
evalin('base','input.google.maps.lat=min(input.google.maps.lat+10/(input.google.maps.zoom),80);')
updateGoogleMap(h)
function pushbuttonPanSouth_Callback(hObject, eventdata, h)
evalin('base','input.google.maps.lat=max(input.google.maps.lat-10/input.google.maps.zoom,-80);')
updateGoogleMap(h)
function zoomOut_Callback(hObject, eventdata, h)
evalin('base','input.google.maps.zoom = max(input.google.maps.zoom-1,1);')
updateGoogleMap(h)
function zoomIn_Callback(hObject, eventdata, h)
evalin('base','input.google.maps.zoom = min(input.google.maps.zoom+1,20);')
updateGoogleMap(h)

%LOCAL FUNCTION ONLY ------------------------------------------------------
function clearInvalidCheckBoxes(handles)
dValidCount=evalin('base','input.dValid.count');
if dValidCount<1
    set(handles.checkbox12,'Value',0) %ML1
    set(handles.checkbox13,'Value',0) %ML2
    set(handles.checkbox14,'Value',0) %ML4
    set(handles.checkbox15,'Value',0) %ML4
    set(handles.checkbox8,'Value',0) %triINM
end
updateVars(handles)
function clearSurfaceCheckBoxes(hObject,handles) %clears all surf plot checkboxes
toggleState = get(hObject,'Value'); %get calling functions checkbox status
set(handles.checkbox4,'Value',0) %clear ALL surface checkboxes
set(handles.checkbox6,'Value',0)
set(handles.checkbox9,'Value',0)
set(handles.checkbox12,'Value',0)
set(handles.checkbox13,'Value',0)
set(handles.checkbox15,'Value',0) %ML3
set(hObject,'Value',toggleState); %return calling function's checkbox to original status
function disableButtons(handles)
set(handles.axes1,'HitTest','off')
set(handles.figure1,'Pointer','watch')
%set(handles.pushbuttonReset,'Enable','off') %reset?
set(handles.editNoiseMultiplier,'Enable','off')
set(handles.pushbuttonStartMC,'Enable','off')
set(handles.pushbuttonRun1MC,'Enable','off')
set(handles.popupmenuConfidencePercent,'Enable','off')
set(handles.popupmenuDetectorMass,'Enable','off')
set(handles.editReactorPower,'Enable','off')
set(handles.editReactorPowerMLEIG,'Enable','off')
set(handles.editPriorRP2,'Enable','off')
set(handles.checkbox1,'Enable','off')
set(handles.checkbox4,'Enable','off')
set(handles.checkbox6,'Enable','off')
set(handles.checkbox8,'Enable','off')
set(handles.checkbox9,'Enable','off')
set(handles.checkbox10,'Enable','off')
set(handles.checkbox12,'Enable','off')
set(handles.checkbox13,'Enable','off')
set(handles.checkbox14,'Enable','off')
set(handles.checkbox15,'Enable','off')
set(handles.togglebuttonMCmode,'Enable','off')
set(handles.editMCrunCount,'Enable','off')
set(handles.editPriorRP1,'Enable','off')
set(handles.editPriorRP2,'Enable','off')
set(handles.radiobuttonReactor,'Enable','off')
set(handles.radiobuttonExplosion,'Enable','off')
set(handles.listboxCriteria,'Enable','off')
set(handles.pushbuttonGoogleEarth,'Enable','off')
drawnow
function enableButtons(handles)
set(handles.axes1,'HitTest','on')
set(handles.figure1,'Pointer','arrow')
set(handles.editNoiseMultiplier,'Enable','on')
dValidCount = evalin('base','input.dValid.count');
dCount = evalin('base','input.dCount');
set(handles.pushbuttonReset,'Enable','on')
set(handles.popupmenuConfidencePercent,'Enable','on')
set(handles.checkbox1,'Enable','on')
set(handles.checkbox4,'Enable','on')
set(handles.checkbox10,'Enable','on') %verbose   
set(handles.editPriorRP1,'Enable','on')
set(handles.editPriorRP2,'Enable','on')
set(handles.pushbuttonGoogleEarth,'Enable','on')
if dCount>0
    set(handles.togglebuttonMCmode,'Enable','on')
    set(handles.editReactorPowerMLEIG,'Enable','on')
    set(handles.checkbox6,'Enable','on') %CRLB
end
if dValidCount>0
   set(handles.checkbox12,'Enable','on')
   set(handles.checkbox13,'Enable','on')
   set(handles.checkbox14,'Enable','on')
   set(handles.checkbox15,'Enable','on')
   
end
if get(handles.togglebuttonMCmode,'Value')==1 %MCmode
    set(handles.pushbuttonStartMC,'Enable','on')
    set(handles.editMCrunCount,'Enable','on')
else %normal mode
    set(handles.popupmenuDetectorMass,'Enable','on')
    set(handles.editReactorPower,'Enable','on')
    set(handles.editPriorRP2,'Enable','on')
    if dCount>0
        set(handles.pushbuttonRun1MC,'Enable','on')
    end
end
set(handles.radiobuttonReactor,'Enable','on')
set(handles.radiobuttonExplosion,'Enable','on')
set(handles.listboxCriteria,'Enable','on')
function updateVars(h)
evalin('base',['flags.status.CRLB=' num2str(get(h.checkbox6, 'Value')) ';'])
evalin('base',['flags.status.ML0=' num2str(get(h.checkbox4, 'Value')) ';'])
evalin('base',['flags.status.verbose=' num2str(get(h.checkbox10, 'Value')) ';'])
evalin('base',['flags.status.ML1=' num2str(get(h.checkbox12, 'Value')) ';'])
evalin('base',['flags.status.ML2=' num2str(get(h.checkbox13, 'Value')) ';'])
evalin('base',['flags.status.ML4=' num2str(get(h.checkbox14, 'Value')) ';'])
evalin('base',['flags.status.ML3=' num2str(get(h.checkbox15, 'Value')) ';'])
if str2double(get(h.textMCrun,'String'))>1
    evalin('base',['flags.status.MCmode=' num2str(get(h.togglebuttonMCmode, 'Value')) ';'])
else
    evalin('base','flags.status.MCmode=0;')
end
idx = get(h.popupmenuDetectorMass, 'Value');
evalin('base',['input.di=' num2str(idx) ';']);
evalin('base','input.detectorMass=table.d(input.di).detector.volume * 1000;') %m^3 to kg
evalin('base','input.detectorProtons=input.detectorMass/1E6*.62E32;')

evalin('base',['input.dNoiseMultiplier=max(' get(h.editNoiseMultiplier,'String') ',0);'])

evalin('base',['flags.status.EstMenuUseRPPriorEquation=' num2str( strcmp(get(h.EstMenuUseRPPriorEquation,'Checked'),'on')) ';'])
evalin('base',['flags.status.EstMenuEnergyCut=' num2str( strcmp(get(h.EstMenuEnergyCut,'Checked'),'on')) ';'])
evalin('base',['flags.status.EstMenuPlotMarginal=' num2str( strcmp(get(h.EstMenuPlotMarginal,'Checked'),'on')) ';'])

p = evalin('base','table.d(input.di).candidateFraction')*100; %candidate percents
namestr = evalin('base','table.d(input.di).candidatenames');
n = size(p,2);
cells = cell(1,n);
for i = 1:n
    cells{i} = sprintf('%s - (%.1f%%)', namestr{i}, mean(p(:,i)));
end
set(h.listboxCriteria,'String',cells)
idx = get(h.listboxCriteria, 'Value');
evalin('base',['input.ci=' num2str(idx) ';'])

n = evalin('base','numel(table.d)');
cells = cell(1,n);
for i = 1:n
    volumestr = evalin('base',['table.d(' num2str(i) ').detector.prettyvolume']);
    namestr = evalin('base',['table.d(' num2str(i) ').name']);
    cells{i} = [namestr ', ' volumestr];
end
set(h.popupmenuDetectorMass,'String',cells)

idx = get(h.popupmenuConfidencePercent, 'Value'); rows = [50, 68.2689492, 90, 95.4499736, 99, 99.7300204];
evalin('base',['input.CEValue=' num2str(rows(idx)) ';'])
evalin('base',['input.plotTime=input.detectorCollectTime;'])

evalin('base',['input.reactor.power=' get(h.editReactorPower, 'String') ';'])
evalin('base',['input.reactor.powerMLEIG=' get(h.editReactorPowerMLEIG, 'String') ';']) %MLE initial guess
evalin('base',['input.MCrunCount=' get(h.editMCrunCount, 'String') ';'])

str =  get(h.editPriorRP1, 'String');
evalin('base',['input.priors.rp1=' str '; input.rp1=' str ';'])
str =  get(h.editPriorRP2, 'String');
evalin('base',['input.priors.rp2=' str '; input.rp2=' str '; input.rpVec = linspace(input.rp1,input.rp2,input.nrp); '])

explosionFlag = get(h.radiobuttonExplosion,'value');
evalin('base',['flags.explosion=' num2str(explosionFlag) ';'])
if explosionFlag
   set(h.radiobuttonReactor,'value',0)
   set(h.radiobuttonExplosion,'value',1)
   set(h.text8,'string','(kTon) True Explosion Yield')
   set(h.text16,'string','(kTon) Estimated Explosion Yield')
   set(h.text9,'string','(kTon) min prior')
   set(h.text22,'string','(kTon) max prior')
   set(h.text7,'visible','off')
else   
   set(h.radiobuttonReactor,'value',1) 
   set(h.radiobuttonExplosion,'value',0)
   set(h.text8,'string','(GW) True Reactor Power')
   set(h.text16,'string','(GW) Estimated Reactor Power')
   set(h.text9,'string','(GW) min prior')
   set(h.text22,'string','(GW) max prior')
   set(h.text7,'visible','on')
end

evalin('base','flags.status.mapElevation=0; flags.status.mapIAEABackground=0; flags.status.mapCrustBackground=0; flags.status.mapCombinedBackground=0;');
if strcmp(get(h.MapMenuPlotElevation,'Checked'),'on');
    evalin('base','flags.status.mapElevation=1;');
elseif strcmp(get(h.MapMenuPlotIAEABackground,'Checked'),'on');
    evalin('base','flags.status.mapIAEABackground=1;');
elseif strcmp(get(h.MapMenuPlotCrustBackground,'Checked'),'on');
    evalin('base','flags.status.mapCrustBackground=1;');
elseif strcmp(get(h.MapMenuPlotCombinedBackground,'Checked'),'on');
    evalin('base','flags.status.mapCombinedBackground=1;');
end

if strcmp(get(h.MapMenuPlotContours,'Checked'),'on'); 
    evalin('base','flags.status.mapContours=1;')
else
    evalin('base','flags.status.mapContours=0;')
end

flag = strcmpi(get(h.MapMenuPlotIAEAreactors,'Checked'),'on'); 
evalin('base',['flags.status.mapIAEAreactors=' num2str(flag) ';'])


if get(h.checkbox1,'Value')==1; 
    evalin('base','flags.status.mapGoogle=1;');
else
    evalin('base','flags.status.mapGoogle=0;');
end

if strcmp(get(h.MapMenuGoogleHybrid,'Checked'),'on');
    evalin('base','input.google.maps.mapType=''hybrid'';');
elseif strcmp(get(h.MapMenuGoogleTerrain,'Checked'),'on');
    evalin('base','input.google.maps.mapType=''terrain'';');
elseif strcmp(get(h.MapMenuGoogleRoadmap,'Checked'),'on');
    evalin('base','input.google.maps.mapType=''roadmap'';');
end

if strcmp(get(h.SeaMenuDetectorFloat,'Checked'),'on');
    evalin('base','flags.status.SeaMenuDetectorFloat=1;');
else
    evalin('base','flags.status.SeaMenuDetectorFloat=0;');
end

if strcmp(get(h.SeaMenuDetectorSink,'Checked'),'on');
    evalin('base','flags.status.SeaMenuDetectorSink=1;');
else
    evalin('base','flags.status.SeaMenuDetectorSink=0;');
end

if strcmp(get(h.SeaMenuDetectorSinkCustom,'Checked'),'on');
    evalin('base','flags.status.SeaMenuDetectorSinkCustom=1;');
else
    evalin('base','flags.status.SeaMenuDetectorSinkCustom=0;');
end
depth = get(h.SeaMenuDetectorSinkCustom,'UserData');
evalin('base',sprintf('input.detectorSinkDepth = %f;',depth))

if strcmp(get(h.SeaMenuWGS84,'Checked'),'on');
    evalin('base','flags.status.SeaMenuWGS84=1; flags.status.SeaMenuEGM96=0; flags.status.SeaMenuEGM2008=0;');
elseif strcmp(get(h.SeaMenuEGM96,'Checked'),'on');
    evalin('base','flags.status.SeaMenuWGS84=0; flags.status.SeaMenuEGM96=1; flags.status.SeaMenuEGM2008=0;');
elseif strcmp(get(h.SeaMenuEGM2008,'Checked'),'on');
    evalin('base','flags.status.SeaMenuWGS84=0; flags.status.SeaMenuEGM96=0; flags.status.SeaMenuEGM2008=1;');
end

drawnow
function AllFlagUpdate(h)
evalin('base',['flags.update.CRLB=' num2str(get(h.checkbox6, 'Value')) ';'])
evalin('base',['flags.update.ML0=' num2str(get(h.checkbox4, 'Value')) ';'])
evalin('base',['flags.update.ML1=' num2str(get(h.checkbox12, 'Value')) ';'])
evalin('base',['flags.update.ML2=' num2str(get(h.checkbox13, 'Value')) ';'])
evalin('base',['flags.update.ML4=' num2str(get(h.checkbox14, 'Value')) ';'])
evalin('base',['flags.update.ML3=' num2str(get(h.checkbox15, 'Value')) ';'])

function checkMCmode(handles)
if str2double(get(handles.textMCrun,'String'))>0 %if MC runs are loaded up in dMCn, delete them
    for n = 1:2 %blink to show that MC are being erased
        set(handles.textMCrun,'ForegroundColor',[0 1 0])
        set(handles.uipanel4,'HighlightColor',[0 1 0]) %green edge
        set(handles.uipanel4,'ForegroundColor',[0 1 0])
        pause(.1)
        set(handles.textMCrun,'ForegroundColor',[.5 .5 .5])
        set(handles.uipanel4,'HighlightColor',[1 1 1])
        set(handles.uipanel4,'ForegroundColor',[0 0 0])
        pause(.1)
    end
    set(handles.textMCrun,'String','0')
end
function figure1_WindowButtonDownFcn(hObject, ~, h)
[insideFlag, xy] = testAxesXY(hObject, h);
clickType = get(gcbf, 'SelectionType'); %normal, alt or open, for left, right and double clicks
leftClick = strcmp(clickType,'normal');
%rightClick = strcmp(clickType,'alt');
if insideFlag && leftClick
    disableButtons(h)
    MCmode = get(h.togglebuttonMCmode,'Value');
    title('Processing Click...','Fontsize',25); drawnow
    if evalin('base','flags.reactorPlaced') %if reactor already placed
        if evalin('base','input.dCount')>0 %if one detector already placed
            %FIND CLOSEST DETECTOR/REACTOR
            xlim = get(h.axes1,'XLim');
            ylim = get(h.axes1,'Ylim');
            maxRadius = min([xlim(2)-xlim(1) ylim(2)-ylim(1)])*.06; %distance in km from detector that a click will work
            for m=1:evalin('base','input.dCount')
                r(m) = norm([evalin('base',['d(' num2str(m) ').position'])+[-.05 .25]*maxRadius ] - xy);
            end
            [val, minRow] = min(r);
            
            if val<maxRadius %if clicked within 20km of detector
                m=minRow;
                enabled = evalin('base',['input.dEnabled(' num2str(m) ')']);
                if enabled && leftClick %if enabled AND left click, disable
                    AllFlagUpdate(h); 
                    clearInvalidCheckBoxes(h)
                    evalin('base',['input.dEnabled(' num2str(m) ')=0; updatePlots'])
                    title(sprintf('Detector %.0f Disabled.',m),'Fontsize',25)
                elseif ~enabled && leftClick %if disabled AND left click, enable
                    AllFlagUpdate(h); 
                    evalin('base',['input.dEnabled(' num2str(m) ')=1; updatePlots'])
                    title(sprintf('Detector %.0f Enabled.',m),'Fontsize',25)
                else
                    title('No Action Taken.','Fontsize',25)
                end
            elseif leftClick && ~MCmode
                checkMCmode(h); AllFlagUpdate(h);
                evalin('base',['xi=' num2str(xy(1)) '; yi=' num2str(xy(2)) '; create1Detector;']);
            else
                title('No Action Taken.','Fontsize',25)
            end
            
        elseif leftClick && ~MCmode
            checkMCmode(h); AllFlagUpdate(h);
            evalin('base',['xi=' num2str(xy(1)) '; yi=' num2str(xy(2)) '; create1Detector;']);
        else
            title('No Action Taken.','Fontsize',25)
        end
    elseif leftClick && ~MCmode
        checkMCmode(h); AllFlagUpdate(h);
        evalin('base',['xi=' num2str(xy(1)) '; yi=' num2str(xy(2)) '; create1Detector;']);
    else
        title('No Action Taken.','Fontsize',25)
    end
    enableButtons(h)
end
function updateGoogleMap(h)
disableButtons(h)
AllFlagUpdate(h)
evalin('base','deleteAllSurfHandles; [input, d, handles] = fcnUpdateGoogleMap(input, d, handles, flags, table); updatePlots;')
enableButtons(h)

%UNDER CONSTRUCTION -------------------------------------------------------

%ADDCHECKBOX CHECKLIST
%1. add to enableButtons and disableButtons callbacks
%2. add to updateVars callback
%3. add to AllFlagUpdate callback
%4. add to clearInvalidCheckboxes callback
%5. add to clearSurfaceCheckboxes callback if it plots a surface
%6. add to pushbuttonReset
%7. add to init.m
%8. add to updatePlots.m
%9. add to deleteAllSurfHandles.m
%10. add to function AllFlagUpdate(h)

function GridMenuGridOn_Callback(hObject, eventdata, handles)
checked = get(hObject,'Checked');
if strcmp(checked,'on') %turn off
    grid off
    set(hObject,'Checked','off');
else %turn on
    grid on
    set(hObject,'Checked','on');
end

function MapMenuPlotContours_Callback(hObject, ~, h)
MapMenuUpdateForeground(hObject, h)
function MapMenuPlotIAEAreactors_Callback(hObject, ~, h)
MapMenuUpdateForeground(hObject, h)
function MapMenuUpdateForeground(hObject, h)
checkedString = get(hObject,'Checked');
set(hObject, 'Checked', 'off')
if strcmp(checkedString ,'off')
    set(hObject,'Checked','on');
end
updateVars(h)
updateGoogleMap(h)

function MapMenuPlotElevation_Callback(hObject, ~, h)
MapMenuUpdateBackground(hObject,h)
if strcmp(get(hObject,'Checked'),'on')
    disableButtons(h)
    evalin('base','handles.mapOverlay = [handles.mapOverlay fcnPlotElevations(input)];') %plots!
    enableButtons(h)
end
function MapMenuPlotIAEABackground_Callback(hObject, ~, h)
MapMenuUpdateBackground(hObject,h)
function MapMenuPlotCrustBackground_Callback(hObject, ~, h)
MapMenuUpdateBackground(hObject,h)
function MapMenuPlotCombinedBackground_Callback(hObject, ~, h)
MapMenuUpdateBackground(hObject,h)
function MapMenuUpdateBackground(hObject, h)
checkedString = get(hObject,'Checked');
set([h.MapMenuPlotElevation, h.MapMenuPlotIAEABackground, h.MapMenuPlotCrustBackground, h.MapMenuPlotCombinedBackground], 'Checked', 'off')
if strcmp(checkedString ,'off')
    set(hObject,'Checked','on');
end
updateVars(h)
updateGoogleMap(h)


function MapMenuGoogleHybrid_Callback(hObject, ~, h)
set([h.MapMenuGoogleRoadmap, h.MapMenuGoogleHybrid, h.MapMenuGoogleTerrain], 'Checked', 'off')
set(hObject,'Checked','on')
evalin('base', 'input.google.maps.mapType = ''hybrid''; ');
updateGoogleMap(h)
function MapMenuGoogleRoadmap_Callback(hObject, ~, h)
set([h.MapMenuGoogleRoadmap, h.MapMenuGoogleHybrid, h.MapMenuGoogleTerrain], 'Checked', 'off')
set(hObject,'Checked','on')
evalin('base', 'input.google.maps.mapType = ''roadmap''; ');
updateGoogleMap(h)
function MapMenuGoogleTerrain_Callback(hObject, ~, h)
set([h.MapMenuGoogleRoadmap, h.MapMenuGoogleHybrid, h.MapMenuGoogleTerrain], 'Checked', 'off')
set(hObject,'Checked','on')
evalin('base', 'input.google.maps.mapType = ''terrain''; ');
updateGoogleMap(h)

function SeaMenuWGS84_Callback(hObject, eventdata, h) %#ok<*DEFNU>
set([h.SeaMenuWGS84, h.SeaMenuEGM96, h.SeaMenuEGM2008], 'Checked', 'off'); set(hObject,'Checked','on')
updateVars(h)
pushbuttonRun1MC_Callback(hObject, eventdata, h)
function SeaMenuEGM96_Callback(hObject, eventdata, h)
set([h.SeaMenuWGS84, h.SeaMenuEGM96, h.SeaMenuEGM2008], 'Checked', 'off'); set(hObject,'Checked','on')
disableButtons(h)
evalin('base','input.EGM = load(''EGM96single.mat''); input.EGM.grid=double(input.EGM.grid);')
updateVars(h)
pushbuttonRun1MC_Callback(hObject, eventdata, h)
function SeaMenuEGM2008_Callback(hObject, eventdata, h)
set([h.SeaMenuWGS84, h.SeaMenuEGM96, h.SeaMenuEGM2008], 'Checked', 'off'); set(hObject,'Checked','on')
disableButtons(h)
evalin('base','input.EGM = load(''EGM2008single.mat'');')
updateVars(h)
pushbuttonRun1MC_Callback(hObject, eventdata, h)
function SeaMenuDetectorFloat_Callback(hObject, eventdata, h)
set([h.SeaMenuDetectorSinkCustom h.SeaMenuDetectorSink], 'Checked', 'off'); set(hObject,'Checked','on')
updateVars(h)
pushbuttonRun1MC_Callback(hObject, eventdata, h)
function SeaMenuDetectorSink_Callback(hObject, eventdata, h)
set([h.SeaMenuDetectorFloat h.SeaMenuDetectorSinkCustom], 'Checked', 'off'); set(hObject,'Checked','on')
updateVars(h)
pushbuttonRun1MC_Callback(hObject, eventdata, h)
function SeaMenuDetectorSinkCustom_Callback(hObject, eventdata, h)
set([h.SeaMenuDetectorFloat h.SeaMenuDetectorSink], 'Checked', 'off'); set(hObject,'Checked','on')
str = inputdlg('Enter Depth in Meters:','Depth',1,{num2str(evalin('base','input.detectorSinkDepth'))});
str = str{1};
try
    depth = eval(str);
    evalin('base',sprintf('input.detectorSinkDepth=%s;',str))
catch
    sprintf('\nWARNING: INVALID SEA DEPTH ENTERED, ASSUMING DEFAULT 1000M DEPTH.\n')
    depth = -1000;
    evalin('base','input.detectorSinkDepth=-1000;');
end
set(h.SeaMenuDetectorSinkCustom,'Label',sprintf('Seaborne Detectors Sink to %.1fm',depth),'UserData',depth)

updateVars(h)
pushbuttonRun1MC_Callback(hObject, eventdata, h)


function figure1_WindowScrollWheelFcn(hObject, eventdata, h)
[insideFlag, xy] = testAxesXY(hObject, h);
if insideFlag
    zoomInFlag = sign(eventdata.VerticalScrollCount)==-1;
    evalin('base',['LLA = fcnGoogleMapsXY2LLA(input, flags, [' num2str(xy) ']); input.google.maps.lat=LLA(1); input.google.maps.lng=LLA(2); clear LLA'])
    if zoomInFlag
        evalin('base','input.google.maps.zoom = min(input.google.maps.zoom+1,20);')
    else %zoomOut
        evalin('base','input.google.maps.zoom = max(input.google.maps.zoom-1,1);')
    end
    centerPointer(h)
    updateGoogleMap(h)
end
function centerPointer(h)
p2 = get(h.figure1,'Position');
p1 = get(h.axes1,'Position');
ss=get(0,'ScreenSize');
p2 = p2.*ss([3 4 3 4]);
p1 = p1.*p2([3 4 3 4]);
p3 = [p1(1)+p1(3)/2, p1(2)+p1(4)/2] + p2(1:2);
set(0,'PointerLocation',p3);


function figure1_WindowButtonMotionFcn(hObject, ~, h)
[insideFlag, xy] = testAxesXY(hObject, h);
if insideFlag   
    lla = evalin('base',['fcnGoogleMapsXY2LLA(input, flags, [' num2str(xy) '])']);
    slla = num2str(lla,8);
             
    rkr = evalin('base',['fcnrange(input.reactor.IAEAdata.unique.ecef,lla2ecef([' slla ']))']);
    [krr, i] = min(rkr);
    krname = evalin('base', ['input.reactor.IAEAdata.unique.sitename{' num2str(i) '}']);
    
    if evalin('base','isfield(input.reactor,''positionECEF'')')
        r = evalin('base',['fcnrange(input.reactor.positionECEF,lla2ecef([' slla ']))']);
        str = sprintf('Lat=%2.6f, Long=%3.6f, Alt=%4.1fm, %s %.5gkm, UR %.5gkm',lla(1),lla(2),lla(3),krname,krr, r);
    else
        str = sprintf('Lat=%2.6f, Long=%3.6f, Alt=%4.1fm, %s %.5gkm',lla(1),lla(2),lla(3),krname,krr); 
    end
    set(h.textCursorInfo,'Visible','on','String',str)
    set([h.pushbuttonPanWest h.pushbuttonPanEast h.pushbuttonPanNorth h.pushbuttonPanSouth],'Visible','on')
    
else
    set(h.textCursorInfo,'Visible','off')
    set([h.pushbuttonPanWest h.pushbuttonPanEast h.pushbuttonPanNorth h.pushbuttonPanSouth],'Visible','off')
end


function [insideFlag, xy] = testAxesXY(hObject, h)
% axesPos = get(h.axes1,'Position');
% xy = get(hObject,'CurrentPoint');
% insideFlag = xy(1)>axesPos(1) && xy(1)<(axesPos(1)+axesPos(3)) && xy(2)>axesPos(2) && xy(2)<(axesPos(2)+axesPos(4)) && strcmp(get(h.axes1,'HitTest'),'on');
% 
% xy = [];
% if insideFlag
%     pixelPos = get(hObject,'CurrentPoint') - axesPos(1,1:2); %click pos in pixels
%     xlim = get(h.axes1,'XLim');
%     ylim = get(h.axes1,'Ylim');
%     pixelPos = pixelPos./axesPos(1,3:4);
%     xpos = xlim(1,1)+pixelPos(1,1)*abs(xlim(1,2)-xlim(1,1)); %interpolate
%     ypos = ylim(1,1)+pixelPos(1,2)*abs(ylim(1,2)-ylim(1,1)); %interpolate
%     xy = [ypos xpos]; %switched x and y axes!
% end
set([hObject h.axes1],'Units','Normalized');
axesPos = get(h.axes1,'Position');
xy = get(hObject,'CurrentPoint');

insideFlag = xy(1)>axesPos(1) && xy(1)<(axesPos(1)+axesPos(3)) && xy(2)>axesPos(2) && xy(2)<(axesPos(2)+axesPos(4)) && strcmp(get(h.axes1,'HitTest'),'on');

xy = [];
if insideFlag
    pixelPos = (get(hObject,'CurrentPoint')-axesPos(1,1:2))./axesPos(1,3:4); %click pos in pixels
    xlim = get(h.axes1,'XLim');
    ylim = get(h.axes1,'Ylim');
    xpos = xlim(1,1)+pixelPos(1)*abs(xlim(1,2)-xlim(1,1)); %interpolate
    ypos = ylim(1,1)+pixelPos(2)*abs(ylim(1,2)-ylim(1,1)); %interpolate
    xy = [ypos xpos]; %switched x and y axes!
end

function EstMenuPlotMarginal_Callback(hObject, eventdata, h)
if strcmp(get(h.EstMenuPlotMarginal,'Checked'),'on');
    set(h.EstMenuPlotMarginal,'Checked','off');
    evalin('base','flags.status.EstMenuPlotMarginal=0;')
else
    set(h.EstMenuPlotMarginal,'Checked','on');
    evalin('base','flags.status.EstMenuPlotMarginal=1;')
end
pushbuttonRunEstimatorsAgain_Callback(hObject, eventdata, h)
function EstMenuEnergyCut_Callback(hObject, eventdata, h)
if strcmp(get(h.EstMenuEnergyCut,'Checked'),'on');
    set(h.EstMenuEnergyCut,'Checked','off');
    evalin('base','flags.status.EstMenuEnergyCut=0;')
else
    set(h.EstMenuEnergyCut,'Checked','on');
    evalin('base','flags.status.EstMenuEnergyCut=1;')
end
AllFlagUpdate(h)
evalin('base','[input, d] = fcnCreateValidDetectorList(input, d);')
pushbuttonRun1MC_Callback(hObject, eventdata, h)

function pushbuttonRunEstimatorsAgain_Callback(hObject, eventdata, h)
disableButtons(h)
AllFlagUpdate(h)
evalin('base','updatePlots')
enableButtons(h)


% --------------------------------------------------------------------
function Filerun_Callback(hObject, eventdata, h)
evalin('base','cd(input.directory)')
%[file, path] = uigetfile([cd '\*.*']);
disableButtons(h)
%file = 'run1';
%if ~isequal(file, 0)
    evalin('base',['run1static'])
%end
enableButtons(h)

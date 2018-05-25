%DEFINE PATHS -------------------------------------------------------------
cp = fcnpathm1(mfilename('fullpath')); cd(cp); addpath(genpath(cp));
cp = fcnpathm1(cp); addpath(cp);

%INITIALIZE UPDATE FLAGS --------------------------------------------------
flags.reactorPlaced = 0;
flags.update.CRLB = 0;
flags.update.ML0 = 0; flags.status.ML0 = 0;
flags.update.ML1 = 0; flags.status.ML1 = 0;
flags.update.ML2 = 0; flags.status.ML2 = 0;
flags.update.ML3 = 0; flags.status.ML3 = 0;
flags.update.ML4 = 0; flags.status.ML4 = 0;
flags.update.crusttiles = 0;
flags.explosion = 0;
flags.upsample = 0;
flags.status.waterprior = 0;
flags.smearosc = 0;
flags.status.aprioribackground = 1;

%SET SEEDS ----------------------------------------------------------------
%input.randomSeed = round(sum(1000*clock)); %get a random seed based on the clock time
%RandStream.getGlobalStream(RandStream('mt19937ar','seed',input.randomSeed));
%reset(RandStream.getGlobalStream)
xlabel('Latitude (deg)'); ylabel('Longitude (deg)');

%DEFINE INPUTS ------------------------------------------------------------
input.dCount                = 0; 
input.dValid.count          = 0;
input.detectorCollectTime   = 365.25 * 1;  %days
input.detectorCollectTime   = 1/60/60/24 * 60;  %for neutron collects
input.detectorSinkDepth     = [];     %meters
input.nxy                   = 401;
axis([0 input.nxy 0 input.nxy]);

dx = 640/input.nxy;
input.google.maps.rescale6402nxy = (dx/2+1/2 : dx : 640-dx/2+1/2);

input.nr                    = 15000; %CHANGE LOOKUP TABLES IF YOU CHANGE THIS!! % number of radius points to evaluate  
input.nrp                   = 90; % number of reactor power points to evaluate

input.r1                    = 1E-6;
input.r2                    = 12900;
input.rVec                  = linspace(input.r1,input.r2,input.nr)';

input.google.maps.zoom=1;
input.google.maps.lat=0;
input.google.maps.lng=0;
input.google.maps.extent=[-1 1 -1 1];
input.ETOPO=[];

%LOAD TABLES --------------------------------------------------------------
input.directory = strrep(pwd,'\','/');
input.scenario = 'No Scenario';
input.EGM = load('EGM96single.mat');  input.EGM.grid=double(input.EGM.grid);
[input.reactor.IAEAdata, input.reactor.IAEAdata.unique] = fcnloadPRIS();

[input, table]=fcnosctables(input, [], flags);  table=fcnmantle(table); %load table.mat
%stable=load('stable.mat');  stable.mantle=table.mantle; stable.udx=table.udx;

flags.smearosc=1; [~, stable] = fcnosctables(input, table, flags); flags.smearosc=0; stable.mantle=table.mantle; stable.udx=table.udx;
% crust=stable.crust; d=stable.d; mev=stable.mev; mantle=stable.mantle; udx=stable.udx; save -v6 stable.mat crust d mev mantle udx; clear crust d mev mantle udx

input.osc.labels = {'\deltam^2_{12}','\Deltam^2_{13}','sin^2(\theta_{12})','sin^2(\theta_{13})'};
input.osc.units = {'eV^2','eV^2','',''};

input.optim.options = optimset('TolX',1E-6,'TolFun',1E-6,'MaxIter',1000,'Display','off','MaxFunEvals',1000,'Algorithm', 'active-set', 'GradObj','on','RelLineSrchBnd',.1,'RelLineSrchBndDuration',1E6);

%CREATE OFFSET SIZE FOR DETECTOR TEXT LABELS ------------------------------
%set(gca,'pointer','fullcrosshair')

%INITIALIZE HANDLES -------------------------------------------------------
handles.detectorText = [];
handles.detectorPoints = [];
handles.reactorText = [];
handles.reactorPoint = [];
handles.IAEAText = [];
handles.IAEAPoints = [];
handles.map = [];
handles.mapContour = [];
handles.mapOverlay = [];
handles.mapIAEABackground = [];
handles.mapCrustBackground = [];
handles.mapCombinedBackground = [];
handles.CRLB = [];
handles.ML0 = []; %combined PDF surface
handles.ML1 = [];
handles.ML2 = [];
handles.ML3 = [];
handles.ML4 = [];
handles.ML123 = [];


%INITIALIZE DETECTORS -----------------------------------------------------
d=[];
[input, d] = fcnCreateValidDetectorList(input, d);

%UPDATE FLUX NOISES -------------------------------------------------------
input = fcnupdatefluxnoise(input, table, d, flags);

%UPDATE TITLE -------------------------------------------------------------
title('Simulation Reset Complete.','Fontsize',25)

%CLEAR UNNEEDED VARIABLES -------------------------------------------------
clear x1 dx cp cp0 i

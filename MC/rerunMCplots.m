% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

directory = cd;
fh = findall(0,'Type','figure'); %figure handles
close(fh(fh~=handles.GUI.figure1));

clc; format short g; tic
cp = addpath(fcnpathm1(mfilename('fullpath')));
[file, path] = uigetfile('*.mat');
if file(1)==0; return; end
cd(path)
scenario = file(1:strfind(file,' SNIF')-1);  ns=numel(scenario);
v1=strfind(file,' D')+1;  detectors=file(v1:v1+find(file(v1:end)==' ',1,'first')-2);

x=what;  x=x.mat;  n=numel(x);

flags2 = flags; flags2.status.mapGoogle=1;
[~, input] = fcnGetGoogleMap(input, flags2);
Cdata = input.google.maps.Cdata;
ETOPO = load('ETOPO1_Ice_g.mat');
EGM = load('EGM96single.mat');  EGM.grid=double(input.EGM.grid);

for i = 1:n
    file1=x{i};  file1=file1(1:end-4);
    v1=strfind(file1,' D')+1;  detectors1=file1(v1:v1+find(file1(v1:end)==' ',1,'first')-2);
    scenario1 = file1(1:strfind(file1,' SNIF')-1);
    
    if strcmp(scenario1,scenario) && strcmp(detectors1,detectors)
        load([file1 '.mat']);
        input.ETOPO = ETOPO;
        input.EGM = EGM;
        input.google.maps.Cdata = Cdata;
        
        flags.upsample = 1;
        h = fcnplotMCresults(input, table, flags, handles, p, mlpoint, systematic, d);
        delete(h);
        set(findobj(0,'Type','text'),'color','k')
        
        %SAVE ALL FIGURES TO FIG FILE ---------------------------------------------
        fprintf('Saving Figures... ')
        fh = findall(0,'Type','figure'); %figure handles
        v1 = fh~=handles.GUI.figure1;
        hgsave(fh(v1),[file1 '.fig'])
        close(fh(v1));
        fprintf('Done\n')
    end
end

cd(directory)
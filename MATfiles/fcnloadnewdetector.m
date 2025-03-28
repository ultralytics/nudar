% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

function []=fcnloadnewdetector()

[FileName,PathName] = uigetfile('*.mat','Select a Detector to Load into the Lookup Table:',[cd '/MATFiles/']);
if FileName(1)==0; return; end
load d.mat

fprintf('Current Detectors:\n')
nd = numel(d);
for i = 1:nd
    fprintf('%.0f:  %s, %s\n',i,d(i).name, d(i).detector.prettyvolume)
end
row = inputdlg('Enter New Detector Row:','Depth',1,{num2str(nd+1)});
if isempty(row); return; end
name = inputdlg('Enter Name:','Depth',1,{'No Name'});
if isempty(name); return; end

load(FileName)
MCtable.d.name = name{1};
d(str2double(row)) = MCtable.d;
save -v6 d.mat d

fprintf('Saved.\n')
end
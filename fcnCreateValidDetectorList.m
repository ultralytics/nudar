% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

function [input, d] = fcnCreateValidDetectorList(input, d)
%BUILD A LIST OF VALID DETECTORS THAT HAVE >0 EVENTS RECORDED BY CURRENTLY REQUESTED DAY
input.dValid.idx                = zeros(1,1);
input.dValid.xy                 = zeros(1,2);
input.dValid.LLA                = zeros(1,3);
input.dValid.events             = zeros(1,1);
input.dValid.validevents        = zeros(1,1);
input.dValid.valideventsidx     = [];

i = 0; %index valid detectors
for idx=1:length(d)
    if input.dEnabled(idx) && d(idx).dutycycle.all>0
        d1 = d(idx);
        v1 = ones(size(d1.z.t)); %d1.z.t<=input.plotTime;
        
        v2 = d1.z.e>=input.ecut.value;
        v4 = find(v1 & v2 & d1.z.candidate);
        nv4 = numel(v4);
        
        i=i+1;
        
        input.dValid.idx(i)               = d1.number;
        input.dValid.events(i)            = sum(v1 & v2);
        input.dValid.validevents(i)       = nv4;
        input.dValid.LLA(i,:)             = d1.positionLLA; %valid detector lat lng heights
        input.dValid.xy(i,:)              = d1.position; %valid detector positions
        input.dValid.valideventsidx{i}    = v4;
        
        d(idx).z.eic                      = d(idx).z.ei(v4);
    end
end
input.dValid.count=i;

end

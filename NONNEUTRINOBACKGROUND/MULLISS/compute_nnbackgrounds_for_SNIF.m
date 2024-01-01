%Compute NN Background for SNIF

function [output]=compute_nnbackgrounds_for_SNIF(d, input, table, fiducial_vol, depth, Ecut, pdfx, pdfy_fn, pdfy_acc, pdfy_cosm)
%fiducial volume in m^3

time=input.detectorCollectTime;   %time exposure in days
%Input Arguments
%depth = depth in MWE
%Ecut = energy cut in visible MeV

%Define SNIF physical characteristics
%fiducial_vol=160000;    %m^3
c12_numdensity=3.79E28; %#/m^3
if fiducial_vol>150000
    radius_of_Edge  = 0;       %not used for SNIF
    radius_of_IV    = 0;         %not used for SNIF
else
    radius_of_Edge  = (3*fiducial_vol/(4*pi))^(1/3);
    radius_of_IV    = radius_of_Edge;         %not used for SNIF
end

%Define SNIF processing parameters
muon_DT=200;            %microseconds
if d.detectordepth<0 %underwater
    %cosmo_DT=100; 
    cosmo_DT = 1500;          %milliseconds
    %cosmo_DT = evalin('base','mcvar.dt');
else
    cosmo_DT=0;
end
%tau=300;                %microsec (delta time used in delayed coincidence filter)
%delta_v=4;            %m^3 (vertex correlation used in delayed coincidence filter)
tau = table.d(input.di).tpn(input.ci);
r = table.d(input.di).rpn(input.ci)/1000; %m
delta_v=4/3*pi*r^3;

%[cosmo_events,cosmo_events_unc,muon_rate,muon_DT_percent,cosmo_DT_percent]=predict_cosmogenic_background(depth,1,time,fiducial_vol,c12_numdensity,muon_DT,cosmo_DT,Ecut);
%[accid_events,accid_events_unc]=predict_accidental_background(time,fiducial_vol,tau,delta_v,radius_of_Edge,Ecut);
%[fastn_events,fastn_events_unc]=predict_fastn_background(depth,1,time,fiducial_vol,radius_of_IV,1,Ecut);

%Note: to use user-specified spectra, define E_cosmo and Prob_cosmo, define E_accid and Prob_accid, define E_fastn and Prob_fastn, and then call:
[cosmo_events,cosmo_events_unc,muon_rate,muon_DT_percent,cosmo_DT_percent]  = predict_cosmogenic_background(depth,1,time,fiducial_vol,c12_numdensity,muon_DT,cosmo_DT,Ecut,pdfx,pdfy_cosm);
[accid_events,accid_events_unc]                                             = predict_accidental_background(time,fiducial_vol,tau,delta_v,radius_of_Edge,Ecut,pdfx,pdfy_acc);
[fastn_events,fastn_events_unc]                                             = predict_fastn_background(depth,1,time,fiducial_vol,radius_of_IV,1,Ecut,pdfx,pdfy_fn);


output=[];
output.cosmo_events=cosmo_events;
output.cosmo_events_unc=cosmo_events_unc;
output.muon_rate=muon_rate;
output.muon_DT_percent=muon_DT_percent;
output.cosmo_DT_percent=cosmo_DT_percent;
output.accid_events=accid_events;
output.accid_events_unc=accid_events_unc;
output.fastn_events=fastn_events;
output.fastn_events_unc=fastn_events_unc;
end
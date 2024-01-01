%Copyright 2011, Integrity Applications Incorporated
%
%Developed by Christopher Mulliss, Senior System Engineer, IAI
%POC: cmulliss@integrity-apps.com, 703-378-8672 x537
%
%Developed on under contract to the United States Government (USG)
%Classification: Unclassified
%
%Restrictions:
%1) Do not redistribute without permission from USG and/or IAI
%2) Not reviewed or approved for release under ITAR
%
%Call for KL: (set scale=1)
%predict_cosmogenic_background(2050,1,1490.8,904.779,3.35E28,2000,2000,0.9)
%
%Call for Borexino: (set scale=2)
%predict_cosmogenic_background(3050,1,365,113.7,3.97E28,2000,2000,1.0)
%
%Call for SNIF from KL: (set scale=1)
%predict_cosmogenic_background(2500,1,365,160000,3.79E28,200,600,0.9)
%predict_cosmogenic_background(2500,1,365,160000,3.79E28,200,600,1.0)
%predict_cosmogenic_background(2500,1,365,160000,3.79E28,200,600,2.6)
%
%Call for SNIF from Borexino: (set scale=2)
%predict_cosmogenic_background(2500,1,365,160000,3.79E28,200,600,0.9)
%predict_cosmogenic_background(2500,1,365,160000,3.79E28,200,600,1.0)
%predict_cosmogenic_background(2500,1,365,160000,3.79E28,200,600,2.6)
%
%Mulliss recommendations for SNIF (from KL): (set scale=1)
%predict_cosmogenic_background(3500,1,365,160000,3.79E28,200,1000,0.9)
%predict_cosmogenic_background(3500,1,365,160000,3.79E28,200,1000,1.0)
%predict_cosmogenic_background(3500,1,365,160000,3.79E28,200,1000,2.6)
%==========================================================================

function [events,events_unc,muon_rate,muon_DT_percent,cosmo_DT_percent]=predict_cosmogenic_background(depth,type,time,fiducial_vol,c12_numdensity,muon_DT,cosmo_DT,Ecut,E,prob)

%Input Parameters
%----------------
%depth=depth in m
%type = 1 for water, 2 for rock
%time in days
%fiducial_vol in m^3
%c12_numdensity = number density of 12C in the LS (for scaling the muon spallation cross section)
%muon_DT: veto in micro-seconds after each and every muon hits the detector (2ms for KL)
%cosmo_DT: veto in milli-seconds after muon induced 9Li/8He cosmogenic decay (2s for KL)
%Ecut: Energy cut in visible prompt energy (MeV)
%
%Optional:
%E: energy of PDF in MeV Visible
%Prob: energy measurement PDF in detector

%Scaling options:
 scale=1;    %Scale from KL 0.9 MeV (Koichi 2007 Ph.D. Thesis)
%scale=2;    %Scale from Borexino 1.0 MeV (Observation of Geo-Neutrinos, Bellini et al., 2010)

if type == 2
    depth=depth*2.7;
end

eff_radius=(3*fiducial_vol/(4*pi))^(1/3);   %Sphere of equivalent volume

%Physical Constants and other assumptions
Li9_lifetime=0.2572;                        %sec; lifetime of cosmic-ray induced 9Li (beta^- + n)
percent_showering_muons=0.15;               %Note: About 3/4 of the cosmogenics come from showering
percent_events_from_showering_muons=0.74;   %From KL measurements

if scale == 1
    %Scaling from KamLand, Ichimura Koichi Thesis 2007
    %
    %Basic Information
    fiducial_vol_ref=904.779;   %m^3 -> 6m radius sphere
    time_exposure_ref=1490.8;   %days
    depth_flat_eq_ref=2050;     %MWE [m]
    c12_numdensity_ref=3.35E28; %C/m^3
    Ecut_ref=0.9;               %MeV in Prompt Visible Energy
    %
    %Rate of cosmogenic 9Li/8He from muons (passing coincidence and fiducial cut)
    showering_muon_ref=959.1;
    showering_muon_uncertainty_ref=33.3;
    nonshowering_muon_ref=336.6;
    nonshowering_muon_uncertainty_ref=26.2;
end

if scale == 2
    %Scaling from Borexino, Bellini et al, 2010 arXiv:1003.0284
    %
    %Basic Information
    fiducial_vol_ref=(100/278)*316;     %100 tons of PC doped with PPO
    time_exposure_ref=365;              %days
    depth_flat_eq_ref=3050;             %MWE [m]
    c12_numdensity_ref=3.97E28;         %C/m^3
    Ecut_ref=1.0;                       %MeV in Prompt Visible Energy
    %
    %Rate of cosmogenic 9Li/8He from muons (passing coincidence and fiducial cut)
    showering_muon_ref=15.4*percent_events_from_showering_muons;
    showering_muon_uncertainty_ref=4;   %(derived to match published rate)
    nonshowering_muon_ref=15.4*(1-percent_events_from_showering_muons);
    nonshowering_muon_uncertainty_ref=4;   %(derived to match published rate)
end


%Processing Parameters and Associated Efficiency
cosmo_veto_time=cosmo_DT/1000;       %2 sec for KL
cosmo_veto_cylinder_radius=3;        %m
cosmo_veto_cylinder_eff=1;           %0.958 for KL, 0.9965 for Borexino (derived to match published rate)
likelihood_selection_eff=1;          %0.891 for KL, 1 for Borexino (derived to match published rate)

%Compute Muon Intensities for scaling
[muon_intensity_ref,muon_average_energy_ref]=predict_muon_intensity(depth_flat_eq_ref,1);
[muon_intensity,muon_average_energy]=predict_muon_intensity(depth,type);

%Compute Duty Cycle loss related to muon_DT (applies to all muons passing thru detector)
if fiducial_vol>150000    %Special case to handle SNIF because it's shape is significantly elongated
    muon_cross_section=(2*23*96.5);                         %m^2
else
    muon_cross_section=pi*eff_radius^2;    %m^2
end
muon_rate=muon_intensity*muon_cross_section/(365*24*60*60); %muon per second
muon_DT_percent=muon_rate*(muon_DT * 1E-6)*100;
if muon_DT_percent >= 100, muon_DT_percent=100; end

%Scale rate of muons
factor=((fiducial_vol*c12_numdensity)/(fiducial_vol_ref*c12_numdensity_ref))*((muon_average_energy/muon_average_energy_ref)^0.73)* (muon_intensity/muon_intensity_ref) * (time/time_exposure_ref);
showering_muon=showering_muon_ref*factor;
showering_muon_uncertainty=showering_muon_uncertainty_ref*factor;
nonshowering_muon=nonshowering_muon_ref*factor;
nonshowering_muon_uncertainty=nonshowering_muon_uncertainty_ref*factor;

%Apply Processing Steps
if cosmo_veto_time == 0  %No Muon Tracking
    events1=showering_muon;
    events1_unc=showering_muon_uncertainty;
    events2=nonshowering_muon;
    events2_unc=nonshowering_muon_uncertainty;
    events3=0;
    events3_unc=0;    
else
    events1=showering_muon*exp(-cosmo_veto_time/Li9_lifetime);
    events1_unc=showering_muon_uncertainty*exp(-cosmo_veto_time/Li9_lifetime);
    events2=nonshowering_muon*exp(-cosmo_veto_time/Li9_lifetime);
    events2_unc=nonshowering_muon_uncertainty*exp(-cosmo_veto_time/Li9_lifetime);
    events3=nonshowering_muon*(1-cosmo_veto_cylinder_eff)/cosmo_veto_cylinder_eff;
    events3_unc=nonshowering_muon_uncertainty*(1-cosmo_veto_cylinder_eff)/cosmo_veto_cylinder_eff;       
end

%Pulling it all together...
events=(events1+events2+events3)*likelihood_selection_eff;
events_unc=sqrt(events1_unc^2+events2_unc^2+events3_unc^2)*likelihood_selection_eff;

%Estimate Duty Cycle loss related to cosmo_DT 
%(Approach tends to overestimate since the entire veto cylinder is assumed to be within the spherical fiducial volume)
%(Approach assumes that all muons hitting the detector go through the LS)
if fiducial_vol>150000    %Special case to handle SNIF because it's shape is significantly elongated
    ave_muon_track_length=37;
else
    ave_muon_track_length=8.74*eff_radius/6.5;  %Scale from KL spherical detector
end
veto_vol_ratio=(pi*(cosmo_veto_cylinder_radius^2)*ave_muon_track_length)/fiducial_vol;
if veto_vol_ratio > 1, veto_vol_ratio=1; end
if eff_radius <= cosmo_veto_cylinder_radius,  veto_vol_ratio=1; end
time_lost_1sec=muon_rate*percent_showering_muons*cosmo_veto_time+muon_rate*(1-percent_showering_muons)*cosmo_veto_time*veto_vol_ratio;
cosmo_DT_percent=100*time_lost_1sec;
if cosmo_DT_percent >= 100, cosmo_DT_percent=100; end


%Apply desired energy cut....
%============================

if Ecut == Ecut_ref     
    %Nothing needs to be done
end
    
if Ecut ~= Ecut_ref

    %User-supplied energy PDF
    if nargin() == 10
        %Ensure normalization
        prob=prob/trapz(E,prob);
    else
        %Define PDF
        E=0:0.01:10;
        prob=cos((E-5.5)/50)-cos((0.9-5.5)/50);
        ind=find(prob < 0);
        prob(ind)=0;
        prob=prob/trapz(E,prob);    
    end
    
    %Step 2: Compute fraction of spectrum above cutoff
    ind=find(E >= Ecut);
    ind_ref=find(E >= Ecut_ref);
    factor=trapz(E(ind),prob(ind));
    factor_ref=trapz(E(ind_ref),prob(ind_ref));
    
    %Step 3
    events=events*factor/factor_ref;
    events_unc=events_unc*factor/factor_ref;
end

end
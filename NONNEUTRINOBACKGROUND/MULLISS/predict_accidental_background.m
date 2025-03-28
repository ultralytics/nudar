% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

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
%Call for KL (set scale=1):
%predict_accidental_background(1490.8,904.779,500.25,8.419,6.5,0.9)
%
%Call for Borexino (set scale=2):
%predict_accidental_background(212.3,195.432,650.00,1.058,4.25,1.0)
%
%Call for SNIF from KL (Use KL coincidence filter) (set scale=1):
%predict_accidental_background(365,160000,500.25,8.419,0,0.9)  
%
%Call for SNIF from KL (set scale=1):
%predict_accidental_background(365,160000,300,1,0,0.9)
%predict_accidental_background(365,160000,300,1,0,1.0)
%predict_accidental_background(365,160000,300,1,0,2.6)
%
%Call for SNIF from Borexino (Use Borexino coincidence filter) (set scale=2):
%predict_accidental_background(365,160000,650.00,1.058,0,1.0)    
%
%Call for SNIF from Borexino (set scale=2):
%predict_accidental_background(365,160000,300,1,0,0.9)
%predict_accidental_background(365,160000,300,1,0,1.0)
%predict_accidental_background(365,160000,300,1,0,2.6)
%
%Call for KL from Borexino (Use KL coincidence filter) (set scale=2):
%predict_accidental_background(1490.8,904.779,500.25,8.419,6.5,0.9)
%
%Call for Borexino from KL (Use Borexino coincidence filter) (set scale=1):
%predict_accidental_background(212.3,195.432,650.00,1.058,4.25,1.0)
%==========================================================================

function [events,events_unc]=predict_accidental_background(time,fiducial_vol,tau,delta_v,radius_of_Edge,Ecut,E,prob)

%Input Parameters
%----------------
%time in days
%fiducial_vol in m^3
%tau in microsec (delta time used in delayed coincidence filter)
%delta_v in m^3 (vertex correlation used in delayed coincidence filter)
%radius_of_Edge: radius of first support structure around LS, in m
%Ecut: Energy cut in visible prompt energy (MeV)
%
%Optional:
%E: energy of PDF in MeV Visible
%Prob: energy measurement PDF in detector

%Scaling options:
%scale=1;    %Scale from KL 0.9 MeV (Koichi 2007 Ph.D. Thesis)
 scale=2;    %Scale from Borexino 1.0 MeV (Observation of Geo-Neutrinos, Bellini et al., 2010)

%Parameters related to rate [# / day / m^3] as a an exponential function of distance from the ballon (or inner vessel wall if they are the same)
eff_rate_tau=0.3;       %m, based on T.Miletic KL Thesis Table 5.5
ratio_edge_to_LS=1400;  %based on T.Miletic KL Thesis Table 5.5, should be > 0 is LS is more radiopure than the support structures, set to 0 to turn off edge effects
%Model: Rate(distance) [# / day / m^3] = Rate_LS + Rate_Edge * exp(-distance/eff_rate_tau), where Rate_Edge = ratio_edge_to_LS * Rate_LS
 
fiducial_radius=(3*fiducial_vol/(4*pi))^(1/3);   %Sphere of equivalent volume

if scale == 1
    %Scaling from KamLand, Ichimura Koichi Thesis 2007
    %
    %Basic Information
    radius_of_Edge_ref=6.5;     %m
    fiducial_radius_ref=6.0;    %m
    fiducial_vol_ref=904.779;   %m^3 -> 6m radius sphere
    time_exposure_ref=1490.8;   %days
    Ecut_ref=0.9;               %MeV in Prompt Visible Energy
    num=80.5;
    num_unc=0.06;
    %
    %Coincidence
    tau_ref=1000; %microsec
    delta_r_ref=2;  %m
    delta_v_ref=(4/3)*pi*(delta_r_ref.^3);   %m^3    
    %
    %Estimate rate (product to rp and rd)
    rate_ref=(num/time_exposure_ref);   
    rate_uncertainty_ref=(num_unc/time_exposure_ref);   
    
     %Compute histogram of volume as function of distance from the IV
    distance_bins_width=0.1;  %m
    distance_bins=(0:distance_bins_width:ceil(fiducial_radius_ref))+distance_bins_width/2;
    vol_in_bins=distance_bins*0;
    for i=1:size(distance_bins,2)
        if (distance_bins(i)-distance_bins_width/2) < fiducial_radius_ref
            vol_in_bins(i)=(4/3)*pi*(min([distance_bins(i)+distance_bins_width/2,fiducial_radius_ref]))^3 - (4/3)*pi*(distance_bins(i)-distance_bins_width/2)^3;
        else
            vol_in_bins(i)=0;
        end
    end
    distance_bins=radius_of_Edge_ref-distance_bins;
    vol_in_bins=fiducial_vol_ref*vol_in_bins/sum(vol_in_bins);  %Renormalize just to be sure
    
    %Find the normalization for the function
    rate_bins=1+ratio_edge_to_LS*exp(-distance_bins/eff_rate_tau);
    eff_rate_scale=rate_ref/sum(rate_bins.*vol_in_bins);
    eff_rate_scale_uncertainty=rate_uncertainty_ref/sum(rate_bins.*vol_in_bins);
    %Rate/vol/time is a now a function of distance from Edge  
    
    eff_rate_scale=eff_rate_scale/(tau_ref*delta_v_ref); 
    eff_rate_scale_uncertainty=eff_rate_scale_uncertainty/(tau_ref*delta_v_ref); 
end

if scale == 2
    %Scaling from Borexino, Bellini et al, 2010 arXiv:1003.0284
    %
    %Basic Information
    radius_of_Edge_ref=4.25;            %m
    fiducial_radius_ref=3.6;           %Assumed fiducial radius used in m
    fiducial_vol_ref=(100/278)*316;     %100 tons of PC doped with PPO
    time_exposure_ref=365;              %days
    Ecut_ref=1.0;                       %MeV in Prompt Visible Energy
    num=0.08;
    num_unc=0.001;   
    %
    %We must apportional exposure properly between time and fiducial volume due to the fact that rate is a function of distance from the IV
    exposure=fiducial_vol_ref*time_exposure_ref;    %m^3 - days
    fiducial_vol_ref=(4/3)*pi*(fiducial_radius_ref^3);
    time_exposure_ref=exposure/fiducial_vol_ref;
    %
    %Coincidence
    tau_ref=1280;     %microsec
    delta_r_ref=1;  %m
    delta_v_ref=(4/3)*pi*(delta_r_ref.^3);   %m^3
    %
    %Estimate rate (product to rp and rd)
    rate_ref=(num/time_exposure_ref);   
    rate_uncertainty_ref=(num_unc/time_exposure_ref);   
    
    %Compute histogram of volume as function of distance from the IV
    distance_bins_width=0.1;  %m
    distance_bins=(0:distance_bins_width:ceil(fiducial_radius_ref))+distance_bins_width/2;
    vol_in_bins=distance_bins*0;
    for i=1:size(distance_bins,2)
        if (distance_bins(i)-distance_bins_width/2) < fiducial_radius_ref
            vol_in_bins(i)=(4/3)*pi*(min([distance_bins(i)+distance_bins_width/2,fiducial_radius_ref]))^3 - (4/3)*pi*(distance_bins(i)-distance_bins_width/2)^3;
        else
            vol_in_bins(i)=0;
        end
    end
    distance_bins=radius_of_Edge_ref-distance_bins;
    vol_in_bins=fiducial_vol_ref*vol_in_bins/sum(vol_in_bins);  %Renormalize just to be sure
    
    %Find the normalization for the function
    rate_bins=1+ratio_edge_to_LS*exp(-distance_bins/eff_rate_tau);
    eff_rate_scale=rate_ref/sum(rate_bins.*vol_in_bins);
    eff_rate_scale_uncertainty=rate_uncertainty_ref/sum(rate_bins.*vol_in_bins);
    %Rate/vol/time is a now a function of distance from Edge  
    
    eff_rate_scale=eff_rate_scale/(tau_ref*delta_v_ref); 
    eff_rate_scale_uncertainty=eff_rate_scale_uncertainty/(tau_ref*delta_v_ref); 
end

%Compute histogram of volume as function of distance from the IV
distance_bins_width=0.1;  %m
%
if fiducial_vol>150000     %Treat SNIF as a special case
    distance_bins=(distance_bins_width/2:distance_bins_width:ceil(23));
    vol_in_bins=distance_bins*0;
    for i=1:size(distance_bins,2)
        eff_len=96.5-2*23+2*distance_bins(i);
        if eff_len > 96.5, eff_len=96.5; end
        vol_in_bins(i)=eff_len*pi*(min([distance_bins(i)+distance_bins_width/2,fiducial_radius]))^2 - eff_len*pi*(distance_bins(i)-distance_bins_width/2)^2;
    end
    distance_bins=23-distance_bins;
    for i=1:size(distance_bins,2)
        vol_in_bins(i)=vol_in_bins(i)+2*( distance_bins_width*pi*(23-distance_bins(i))^2 );
    end    
    vol_in_bins=fiducial_vol*vol_in_bins/sum(vol_in_bins);  %Renormalize just to be sure
else                        %General case of sphere
    distance_bins=(distance_bins_width/2:distance_bins_width:ceil(fiducial_radius));
    vol_in_bins=distance_bins*0;
    for i=1:size(distance_bins,2)
        if (distance_bins(i)-distance_bins_width/2) < fiducial_radius
            vol_in_bins(i)=(4/3)*pi*(min([distance_bins(i)+distance_bins_width/2,fiducial_radius]))^3 - (4/3)*pi*(distance_bins(i)-distance_bins_width/2)^3;
        else
            vol_in_bins(i)=0;
        end
    end
    distance_bins=radius_of_Edge-distance_bins;  
    vol_in_bins=fiducial_vol*vol_in_bins/sum(vol_in_bins);  %Renormalize just to be sure
end
rate_bins=1+ratio_edge_to_LS*exp(-distance_bins/eff_rate_tau);

%Pulling it all together...
events = eff_rate_scale*sum(rate_bins.*vol_in_bins)*time*tau*delta_v;
events_unc=eff_rate_scale_uncertainty*sum(rate_bins.*vol_in_bins)*time*tau*delta_v;

%Apply desired energy cut....
%============================

if Ecut == Ecut_ref     
    %Nothing needs to be done
end
    
if Ecut ~= Ecut_ref
    
    %User-supplied energy PDF
    if nargin() == 8
        %Ensure normalization
        prob=prob/trapz(E,prob);
    else
        %Define PDF
        E=0:0.01:10;
        prob=exp(-(E)/1.7)-exp(-(5.6)/1.7);
        prob(prob < 0)=0;
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
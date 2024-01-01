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
%predict_fastn_background(2050,1,1490.8,904.779,9,2,0.9)
%
%Call for Borexino: (set scale=2)
%predict_fastn_background(3050,1,212.3,195.432,6.85,2,1.0) 
%
%Call for SNIF from KL: (set scale=1)
%predict_fastn_background(2500,1,365,160000,0,1,0.9)
%predict_fastn_background(2500,1,365,160000,0,1,1.0)
%predict_fastn_background(2500,1,365,160000,0,1,2.6)
%
%Call for SNIF from Borexino: (set scale=2)
%predict_fastn_background(2500,1,365,160000,0,1,0.9)
%predict_fastn_background(2500,1,365,160000,0,1,1.0)
%predict_fastn_background(2500,1,365,160000,0,1,2.6)
%==========================================================================

function [events,events_unc]=predict_fastn_background(depth,type,time,fiducial_vol,radius_of_IV,surrounding_type,Ecut,E,prob)

%Input Parameters
%----------------
%depth=depth in m
%type = 1 for water, 2 for rock, 3 for surface
%time in days
%fiducial_vol in m^3
%radius_of_IV = radius of Inner Vessel in m
%surrounding_type = 1 for water, 2 for rock, 3 for surface (mix of air and rock)
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

fiducial_radius=(3*fiducial_vol/(4*pi))^(1/3);   %Sphere of equivalent volume

%Physical Constants and other assumptions   
%(from French SNIF paper, consistent with Borexino)
fraction_from_OD=1/5;                               %Fraction of rate that does NOT scale with the density of the surroundings
fraction_from_surroundings=1-fraction_from_OD;      %Fraction of rate DOES scale with the density of the surroundings

%French state that rate at 3m distance is 0% the peak rate
reference_distance=3;      %m from IV
reference_fraction=0.9;    %fraction of rate within reference distance (assuming equal volumes at all distances from IV)
    
if scale == 1
    %Scaling from KamLand, Ichimura Koichi Thesis 2007
    %
    %Basic Information
    radius_of_IV_ref=9;                                     %m
    fiducial_radius_ref=6;                                  %m
    fiducial_vol_ref=(4/3)*pi*(fiducial_radius_ref^3);      %m^3 -> 6m radius sphere
    time_exposure_ref=1490.8;                               %days
    depth_flat_eq_ref=2050;                                 %MWE [m]
    surrounding_type_ref=2;
    Ecut_ref=0.9;                                           %MeV in Prompt Visible Energy

    %Rate of fastn (passing coincidence and fiducial cut)
    rate_ref=4.5/time_exposure_ref;                         %# / day
    rate_uncertainty_ref=(9/sqrt(12))/time_exposure_ref;    %# / day
%   rate_ref=9/time_exposure_ref;                           %# / day
%   rate_uncertainty_ref=(0.1*9)/time_exposure_ref;         %# / day
    
    %Compute histogram of volume as function of distance from the IV
    distance_bins_width=0.1;  %m
    distance_bins=(0:distance_bins_width:ceil(fiducial_radius_ref))+distance_bins_width/2;
    vol_in_bins=distance_bins*0;
    for i=1:size(distance_bins,2)
        vol_in_bins(i)=(4/3)*pi*(min([distance_bins(i)+distance_bins_width/2,fiducial_radius_ref]))^3 - (4/3)*pi*(distance_bins(i)-distance_bins_width/2)^3;
    end
    distance_bins=radius_of_IV_ref-distance_bins;
    vol_in_bins=fiducial_vol_ref*vol_in_bins/sum(vol_in_bins);  %Renormalize just to be sure
    
    %Fix shape of rate[per vol per time] as a function of distance from IV
    eff_rate_tau=1/(-log(1-reference_fraction)/reference_distance);
    
    %Find the normalization for the function
    rate_bins=exp(-distance_bins/eff_rate_tau);
    eff_rate_scale=rate_ref/sum(rate_bins.*vol_in_bins);
    eff_rate_scale_uncertainty=rate_uncertainty_ref/sum(rate_bins.*vol_in_bins);
    %Rate/vol/time is a now a function of distance from IV: Rate(distance) [#/m^3/day] = eff_rate_scale*exp(-distance/eff_rate_tau)

%     figure(1)
%     plot(0:0.1:9,eff_rate_scale*exp(-(0:0.1:9)/eff_rate_tau));
%     xlabel('Distance from Vessel Edge at Radius = 9m');
%     ylabel('Fast N Rate [# / m^3 / day]');
%     title({'Fast N Rate versus Distance','Scaled from KL Measurements','Decay Constant: 90% within 3m of Edge'});
%     
%     figure(2)
%     plot(distance_bins,vol_in_bins);
%     xlabel('Bins of Distance (m)');
%     ylabel('Total Volume within Bins');
%     title('KL Detector');
    
end

if scale == 2
    %Scaling from Borexino, Bellini et al, 2010 arXiv:1003.0284
    %
    %Basic Information
    radius_of_IV_ref=6.85;              %m
    fiducial_radius_ref=3.6;           %Assumed fiducial radius used in m
    fiducial_vol_ref=(100/278)*316;     %100 tons of PC doped with PPO (scaled to 100 ton - years, not actual fiducial volume)
    time_exposure_ref=365;              %days (scaled to 100 ton - years, not actual live time)
    depth_flat_eq_ref=3050;             %MWE [m]
    surrounding_type_ref=2;
    Ecut_ref=1.0;                       %MeV in Prompt Visible Energy
    %
    %We must apportional exposure properly between time and fiducial volume due to the fact that rate is a function of distance from the IV
    exposure=fiducial_vol_ref*time_exposure_ref;    %m^3 - days
    fiducial_vol_ref=(4/3)*pi*(fiducial_radius_ref^3);
    time_exposure_ref=exposure/fiducial_vol_ref;
    %
    %Rate of fastn (passing coincidence and fiducial cut)
    rate_ref=0.025/time_exposure_ref;                          %# / day
    rate_uncertainty_ref=(0.05/sqrt(12))/time_exposure_ref;    %# / day    
%   rate_ref=0.025/time_exposure_ref;                          %# / day
%   rate_uncertainty_ref=(0.1*0.025)/time_exposure_ref;        %# / day    

    %Compute histogram of volume as function of distance from the IV
    distance_bins_width=0.1;  %m
    distance_bins=(distance_bins_width/2:distance_bins_width:ceil(fiducial_radius_ref));
    vol_in_bins=distance_bins*0;
    for i=1:size(distance_bins,2)
        if (distance_bins(i)-distance_bins_width/2) < fiducial_radius_ref
            vol_in_bins(i)=(4/3)*pi*(min([distance_bins(i)+distance_bins_width/2,fiducial_radius_ref]))^3 - (4/3)*pi*(distance_bins(i)-distance_bins_width/2)^3;
        else
            vol_in_bins(i)=0;
        end
    end
    distance_bins=radius_of_IV_ref-distance_bins;  
    vol_in_bins=fiducial_vol_ref*vol_in_bins/sum(vol_in_bins);  %Renormalize just to be sure
    
    %Fix shape of rate[per vol per time] as a function of distance from IV
    eff_rate_tau=1/(-log(1-reference_fraction)/reference_distance);
    
    %Find the normalization for the function
    rate_bins=exp(-distance_bins/eff_rate_tau);
    eff_rate_scale=rate_ref/sum(rate_bins.*vol_in_bins);
    eff_rate_scale_uncertainty=rate_uncertainty_ref/sum(rate_bins.*vol_in_bins);
    %Rate/vol/time is a now a function of distance from IV: Rate(distance) [#/m^3/day] = eff_rate_scale*exp(-distance/eff_rate_tau)
    
end

%Compute Muon Intensities for scaling
[muon_intensity_ref,muon_average_energy_ref]=predict_muon_intensity(depth_flat_eq_ref,1);
[muon_intensity,muon_average_energy]=predict_muon_intensity(depth,type);

%Scale rate for muon energy and intensity
factor=((muon_average_energy/muon_average_energy_ref)^0.73) * (muon_intensity/muon_intensity_ref);
eff_rate_scale=eff_rate_scale*factor;
eff_rate_scale_uncertainty=eff_rate_scale_uncertainty*factor;

%Scale rate to account for different types of surroundings (if needed)
if surrounding_type_ref==2 & surrounding_type==1
    factor=(fraction_from_OD + fraction_from_surroundings/2.7);
    eff_rate_scale=eff_rate_scale*factor;
    eff_rate_scale_uncertainty=eff_rate_scale_uncertainty*factor;    
end
if surrounding_type_ref==2 & surrounding_type==3
    factor=(fraction_from_OD + fraction_from_surroundings/6.0);
    eff_rate_scale=eff_rate_scale*factor;
    eff_rate_scale_uncertainty=eff_rate_scale_uncertainty*factor;    
    %
    %Factor of 8 comes from:
    %-----------------------
    %rho_rock / rho_air ~ 2241
    %Consider a cube sitting on surface: 1 side "touches" rock and 5 sides "touch" air
    %Factor = ((1/6)*(1/1) + (5/6)*(1/2241))^-1 = 5.9866 ~ 6.0
    %*This is simply an assertion, no measurements known to the author back it up
end

%Compute histogram of volume as function of distance from the IV
distance_bins_width=0.1;  %m
%
if fiducial_vol>150000     %Treat SNIF as a special case
    distance_bins=(distance_bins_width/2:distance_bins_width:ceil(23));
    vol_in_bins=distance_bins*0;
    for i=1:size(distance_bins,2)
        eff_len=96.5-2*23+2*distance_bins(i);
        if eff_len > 96.5, eff_len=96.5;, end
        vol_in_bins(i)=eff_len*pi*(min([distance_bins(i)+distance_bins_width/2,fiducial_radius]))^2 - eff_len*pi*(distance_bins(i)-distance_bins_width/2)^2;
    end
    distance_bins=23-distance_bins;
    for i=1:size(distance_bins,2)
        vol_in_bins(i)=vol_in_bins(i)+2*( distance_bins_width*pi*(23-distance_bins(i))^2 );
    end  
    vol_in_bins=fiducial_vol*vol_in_bins/sum(vol_in_bins);  %Renormalize just to be sure
    
%     figure(3)
%     plot(distance_bins,vol_in_bins);
%     xlabel('Bins of Distance (m)');
%     ylabel('Total Volume within Bins (m^3)');
%     title('SNIF Detector');
    
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
    distance_bins=radius_of_IV-distance_bins;  
    vol_in_bins=fiducial_vol*vol_in_bins/sum(vol_in_bins);  %Renormalize just to be sure
end

%Pulling it all together...
events = eff_rate_scale*sum(exp(-distance_bins/eff_rate_tau).*vol_in_bins)*time;
events_unc=eff_rate_scale_uncertainty*sum(exp(-distance_bins/eff_rate_tau).*vol_in_bins)*time;

%Apply desired energy cut....
%============================

if Ecut == Ecut_ref     
    %Nothing needs to be done
end

if Ecut ~= Ecut_ref
    
    %User-supplied energy PDF
    if nargin() == 9
        %Ensure normalization
        prob=prob/trapz(E,prob);
    else
        %Define PDF
        E=0.0:0.01:10;
        prob=E*0;
        ind=find(E >= 0.9);
        prob(ind)=1;
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
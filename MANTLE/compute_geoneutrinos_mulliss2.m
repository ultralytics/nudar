% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

%Compute GeoNeutrinos
%Mulliss, 5 Oct 2010 
%Using PREM for density profile, and abundances from Bulk Silicate Earth (BSE) Model

function [fluxdensity, abundances] = compute_geoneutrinos_mulliss2(r)
nr = numel(r); %radius in km from center earth
abundances = zeros(nr,3);
%MANTLE FROM 3480 to 6291km!!

% i = find(r >= 3480 & r < 5600);
% abundances(i,1)=13.2E-9;
% abundances(i,2)=52E-9;
% abundances(i,3)=1.6E-4;
% 
% i = find(r >= 5600 & r < 6291);
% abundances(i,1)=6.5E-9;
% abundances(i,2)=17.3E-9;
% abundances(i,3)=0.78E-4;
% 
% i = find(r >= 6291 & r < 6346.6);
% abundances(i,1)=0.62E-6;
% abundances(i,2)=3.7E-6;
% abundances(i,3)=0.72E-2;
% 
% i = find(r >= 6346.6 & r < 6356);
% abundances(i,1)=1.6E-6;
% abundances(i,2)=6.1E-6;
% abundances(i,3)=1.67E-2;
% 
% i = find(r >= 6356 & r < 6368);
% abundances(i,1)=2.5E-6;
% abundances(i,2)=9.8E-6;
% abundances(i,3)=2.57E-2;
% 
% i = find(r >= 6368 & r < 6371);
% abundances(i,1)=1.68E-6;
% abundances(i,2)=6.9E-6;
% abundances(i,3)=1.7E-2;


i = find(r>=3480 & r<6371);
abundances(i,1) = 0.0109E-6; %U elemental abundance
abundances(i,2) = 0.0220E-6; %Th elemental abundance
abundances(i,3) = 0.0151E-2; %K elemental abundance


%0.0109E-6    0.0220E-6      0.0151E-2     ];    %Steve Dye's HPE homogeneous mantle 4/10/2015
%   9E-9     0.022E-6      0.015E-2     ];    %9. upper mantle -Huang's 'DM' Depleted Mantle

density = fcnPREM(r); 

%ISOTOPE MASSES -----------------------------------------------------------
amu=1.660538782E-24; %g
%                   [u238           th232       k40         ]
isotope_abundance = [0.992745       1.0         0.000117    ];
lifetime =          [6.446          20.212      1.8005      ] * (1E9*365.25*24*60*60); %Gyr to seconds (lifetime = halflife/log(2))
multiplicity =      [6              4           0.893       ]; %nuebars/decay
mass =              [238.0507826    232.0381    39.96399848 ]*amu;

abundance=bsxfun(@times,abundances,isotope_abundance); %Compute total abundance
isotope_density=bsxfun(@times,abundance,density); %Compute total density for radioactive species
fluxdensity = bsxfun(@times,isotope_density,multiplicity./(lifetime.*mass));  %(#/cm^3/s) anti-neutrino fluxes
end

% fig;
% r = linspace(0,6371,1E4);
% plot(r,abundances(:,1),'r','DisplayName','U abundance');
% plot(r,abundances(:,2),'g','DisplayName','Th abundance');
% plot(r,abundances(:,3),'b','DisplayName','K abundance');
% plot(r,density,'k','DisplayName','PREM density (g/cm^3)'); set(gca,'yscale','log')
% xyzlabel('Earth Radius (km)','')





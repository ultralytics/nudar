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
%==========================================================================

function [intensity,Average_E_GeV]=predict_muon_intensity(depth,type)

%depth=depth in m
%type = 1 for water, 2 for rock

if (nargin == 2)
    if type == 2
        depth=depth*2.7;
    end
end

%Reference:
%Muon-Induced Background Study for Underground Laboratories
%D.-M. Mei and A. Hime
%Physics Division, MS H803,
%Los Alamos National Laboratory,
%Los Alamos, NM 87545, USA
%(Dated: December 5, 2005)

%Equation is valid depths 1 - 10 Km.W.E
%Hard-code an interpolation to handle depths = 0 - 1 Km.W.E

%Integrated muon intensity over hemisphere (eliminate the "per str")
if depth < 1000
    intensity_0km=2140*149804.985/((4/183.834)^0.73);
    if depth == 0
        intensity=intensity_0km;
    else
        p1 = 1.3337e-006;
        p2 = -0.0051514;
        p3 = 9.7195;
        log_int=p1*depth^2 + p2*depth + p3;
        intensity=10^log_int;   %intensity in total number per  m^2 per year
    end
else
    intensity=67.97E-6 * exp(-(depth/1000)/0.285) + 2.071E-6 * exp(-(depth/1000)/0.698);  %intensity in total number per cm^2 per sec
    intensity=intensity*100*100;        %intensity in total number per m^2 per sec
    intensity=intensity*(365*24*60*60); %intensity in total number per  m^2 per year    
end

%Compute Average muon energy
if depth == 0
    Average_E_GeV=4;    %GeV
else
    %Coefficients assume standard rock
    b=0.4;              %[1/Km.W.E]
    gamma_muon=3.77;
    epsilon_muon=693;   %GeV
    Average_E_GeV=epsilon_muon*(1-exp(-b*depth/1000))/(gamma_muon-2);
    if Average_E_GeV < 4
        Average_E_GeV=4;    %Force continuity with measured surface value
    end
end

end
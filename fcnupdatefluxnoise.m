% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

function input = fcnupdatefluxnoise(input, table, d, flags)
if flags.status.aprioribackground
    mu = [.02 .50 .20 .10 .0125 .0327];
else
    ts=[     0.017066      0.34206      0.14594     0.094999     0.012656     0.031623%     %ML1 = SNRx100;
             0.014972      0.25051     0.097758     0.094325     0.011728     0.033342%     %ML2 = SNRx10;
             0.014768      0.26014      0.10201     0.097863     0.012375     0.033044%     %ML3 = SNRx1;
             0.014807      0.20286     0.082987     0.094353     0.012273     0.032866%     %ML3x10 = SNR/10;
             0.015153      0.13891     0.062745     0.095081      0.01232     0.032334%     %ML3x20 = SNR/20;
             0.014594      0.10226     0.053147     0.094121     0.012324     0.034275];%   %ML3x30 = SNR/30;
    mu=interp1([0 1/30 1/20 1/10 1 10 100 inf]',ts([6 6:-1:1 1],:),input.dNoiseMultiplier);
end

%CORRELATED (SYSTEMATIC) FLUX UNCERTAINTY ---------------------------------
input.fluxnoise.systematic.mean = mu*1; %fast neutrons capped at 10%
input.fluxnoise.systematic.rand = (input.fluxnoise.systematic.mean.*randn(size(input.fluxnoise.systematic.mean))*1+1)*1; %random sample 1 sigma
input.fluxnoise.systematic.rand = max(input.fluxnoise.systematic.rand, 0);
input.fluxnoise.systematic.estimated = [1 1 1 1 1 1 1 1];
input.fluxnoise.systematic.labels = {'Known Reactors','Mantle','Crust','Fast Neutrons','Accidentals','Cosmogenic', 'All Geo', 'All Background','Geo-Reactor'};

%UNCORRELATED FLUX UNCERTAINTY --------------------------------------------
input.fluxnoise.uncorrelated.mean = [.034 .08 .024]*1; %reactor is per core
input.fluxnoise.uncorrelated.meanperkrsite = input.fluxnoise.uncorrelated.mean(1)./sqrt(input.reactor.IAEAdata.unique.ncores); %reactor is per core
input.fluxnoise.uncorrelated.rand{1} = input.fluxnoise.uncorrelated.meanperkrsite.*randn(input.reactor.IAEAdata.unique.n,1); %kr
input.fluxnoise.uncorrelated.rand{2} = input.fluxnoise.uncorrelated.mean(2) * randn(table.crust.all.n,1); %Crust
input.fluxnoise.uncorrelated.rand{3} = 1 + input.fluxnoise.uncorrelated.mean(3) * randn(1E3,1); %Crust
input.fluxnoise.uncorrelated.labels = {'Known Reactors','Crust','Detector'};

%COMBINE FLUX NOISES ------------------------------------------------------
if input.dValid.count==0
    cf = .73; %crust fraction of total geo uncertainty (about 73%)
    af = [.19 .18 .52 .02 .08 .01];
else
    cf = 0;
    af = zeros(size(input.fluxnoise.systematic.mean)); %all fraction
    for i = 1:input.dValid.count
        d1 = d(input.dValid.idx(i));
        
        if ~isempty(d1.epdf)          
            cf = cf + d1.n.crust/d1.n.allgeo/input.dValid.count;
            af = af + [d1.n.kr d1.n.mantle d1.n.crust d1.n.fastneutron d1.n.accidental d1.n.cosmogenic]./d1.n.all./input.dValid.count;
        end
    end
end
input.fluxnoise.systematic.cf = cf;
input.fluxnoise.systematic.af = af;

mantleunc = input.fluxnoise.systematic.mean(2);
crustunc = input.fluxnoise.systematic.mean(3);
geouncsigma = norm([mantleunc*(1-cf) crustunc*cf]); %weighted norm EQN VERIFIED 10JUN2011
alluncsigma = norm(input.fluxnoise.systematic.mean.*af);
input.fluxnoise.systematic.mean = [input.fluxnoise.systematic.mean geouncsigma alluncsigma];

mantleunc = input.fluxnoise.systematic.rand(2);
crustunc = input.fluxnoise.systematic.rand(3);
geouncrand = mantleunc*(1-cf) + crustunc*cf; %weighted norm
alluncrand = sum(input.fluxnoise.systematic.rand.*af);
input.fluxnoise.systematic.rand = [input.fluxnoise.systematic.rand geouncrand alluncrand];
end

%clc; std(systematic.true(:,1:6) - systematic.est(:,1:6))

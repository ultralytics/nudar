% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

function [input, table] = fcnosctables(input, table0, flags)
fprintf('Building Oscillation Tables... '); tic
day = input.detectorCollectTime;

%CRUST2.0 TABLES ----------------------------------------------------------
buildcrust = 0;
if buildcrust
    table.crust = fcncrust1p0(input, table0); 
else
    table.crust = load('crust1p0.mat'); 
end
%table.crust.all.flux=table.crust.all.flux(:,1:2);

if ~isempty(table0) && isfield(table0,'mantle')
    table.mantle = table0.mantle;
    table.udx = table0.udx;
    table.d = table0.d;
else
    load d.mat; table.d = d;
end
clear table0

%input.ecut.value = 1.79; %(MeV) %evis=1.71-.7823
%input.ecut.value = 0.79; %(MeV) %evis=.79-.7823
input.ecut.value = 0.01; %(MeV) %evis=.01-.7823
table.mev.de = .01;
table.mev.e = input.ecut.value:table.mev.de:11;
table.mev.evis = table.mev.e-.7823;
table.mev.eall = input.ecut.value:table.mev.de:11;
table.mev.ne = numel(table.mev.e);
input.ecut.v1 = uint16( 1:table.mev.ne );
table.mev.geov1 = uint16( 1:fcnindex1(table.mev.e, 6) ); %geo energy indices
table.mev.egeo = table.mev.e(table.mev.geov1);

f = table.d(input.di).candidateFraction(:,input.ci);
table.mev.cf = interp1([0 2:11]', f([1 1:10]), table.mev.e, 'pchip'); %candidate fraction
table.mev.r=input.rVec;  table.mev.dr=table.mev.r(2)-table.mev.r(1);


if flags.smearosc
    [~, table.osc] = fcnrandosc(1,input,flags);
    if flags.status.aprioribackground %worse!
        s = load('apriori osc fraction 2014.mat');
    else %better!
        [~, i] = min(abs(input.dNoiseMultiplier - [100 10 1 1/10 1/20 1/30]));
        switch i
            case 1;  s=load('aposteriori ML1 osc fraction Bari Group 2012 SNIF home.mat');
            case 2;  s=load('aposteriori ML2 osc fraction Bari Group 2012 SNIF home.mat');
            case 3;  s=load('aposteriori ML3 osc fraction Bari Group 2012 SNIF home.mat');
            case 4;  s=load('aposteriori ML3x10 osc fraction Bari Group 2012 SNIF home.mat');
            case 5;  s=load('aposteriori ML3x20 osc fraction Bari Group 2012 SNIF home.mat');
            case 6;  s=load('aposteriori ML3x30 osc fraction Bari Group 2012 SNIF home.mat');
        end
    end
    v1=fcnindex1(s.MeV,table.mev.e);
    table.mev.fs = double( s.fraction(:,max(v1,1)) ); clear s
else
    [input.osc.true.mu, table.osc] = fcnrandosc(1,input,flags); input.osc.est.mu=table.osc.u;
    %table.mev.fs = fcnspec1f(input.rVec, table.mev.e, input.osc.true.mu);
    table.mev.fs = fcnspec1f(input.rVec, table.mev.e);
end

%IMPORT ELEMENT SPECTRA ---------------------------------------------------
typeNames = {'uranium','thorium','potassium'};
spectrumfileNames = {'AntineutrinoSpectrum_238U.knt','AntineutrinoSpectrum_232Th.knt','AntineutrinoSpectrum_40K.knt'}; %http://www.awa.tohoku.ac.jp/~sanshiro/research/geoneutrino/spectrum/index.html
evecs = {table.mev.e(1):table.mev.de:4.4, table.mev.e(1):table.mev.de:2.3, table.mev.e(1):table.mev.de:1.4};
input.detectorProtons = table.d(input.di).detector.volume*1000/1E6*.62E32;
secPerDay   = 60*60*24;
for i = 1:3
    t               = load(spectrumfileNames{i});
    t(:,1)          = t(:,1)/1000; %kev to mev
    t(:,2)          = t(:,2)/sum(t(:,2)*.001);
    s.e             = evecs{i};
    ei              = fcnindex1(table.mev.e, s.e);

    pdf0            = interp1(t(:,1),t(:,2),s.e')'; %.1kev to 1kev resolution
    pdf0            = pdf0/trapz(s.e,pdf0); %rescale so integral=1, we lost some resolution
    pdfs            = (day*secPerDay*input.detectorProtons)*fcnspecdetection(s.e).*pdf0; %#/detector
    s.pdf0          = pdf0;
    s.pdf           = bsxfun(@times, table.mev.fs(:,ei), pdf0*(1/4/pi)); %flux (#/s/MeV)
    s.pdfs          = bsxfun(@times, table.mev.fs(:,ei), pdfs*(1/4/pi));
    s.ns            = sum(s.pdfs,2)*table.mev.de; %NOT SCALED BY SOLID ANGLE
    eval(['table.mev.' typeNames{i} ' = s;'])
    %fig; plot(t(:,1),t(:,2).*t(:,1),'color',fcndefaultcolors(i,3),'displayname',typeNames{i}); xyzlabel('E_\nu (MeV)','arbitrary')
end

%NONNEUTRINOS -------------------------------------------------------------
e1=table.mev.e;  de1=table.mev.de;  pdf=[];
load('fastneutron.mat');                                s.pdfall=pdf;  s.eall=e;  x=interp1(e',pdf',e1','linear',0)';  s.pdf=x/sum(x)/de1;  s.e=e1;  s.de=de1;  table.mev.fastneutron=s;
load('accidentalKamLAND_BG_Spectrum_ExpExtrap.mat');    s.pdfall=pdf;  s.eall=e;  x=interp1(e',pdf',e1','linear',0)';  s.pdf=x/sum(x)/de1;  s.e=e1;  s.de=de1;  table.mev.accidental=s;
load('cosmogenic.mat');                                 s.pdfall=pdf;  s.eall=e;  x=interp1(e',pdf',e1','linear',0)';  s.pdf=x/sum(x)/de1;  s.e=e1;  s.de=de1;  table.mev.cosmogenic=s;

%REACTOR ------------------------------------------------------------------
table.mev.pdf0  = (day*input.detectorProtons)*table.mev.cf.*fcnspecreactoremission(table.mev.e).*fcnspecdetection(table.mev.e); % # cm^2/day/GWth/p^+
fprintf('Done (%.2fs)\n',toc)

fprintf('Applying Detector %.0f Candidate Index %.0f Energy Smear... ', input.di, input.ci); tic
table.mev.smeared = [];
table.mev.smeared.fastneutron = table.mev.fastneutron.pdf; %no smear no cf
table.mev.smeared.accidental  = table.mev.accidental.pdf; %no smear no cf
table.mev.smeared.cosmogenic  = table.mev.cosmogenic.pdf; %no smear no cf
[~, table.mev.smeared.gpdfs]  = fcnsmearenergy(input, table, table.mev.e,             table.mev.pdf0);
table.mev.smeared.geonu{1}    = fcnsmearenergy(input, table, table.mev.uranium.e,     table.mev.uranium.pdfs,    table.mev.egeo   );
table.mev.smeared.geonu{2}    = fcnsmearenergy(input, table, table.mev.thorium.e,     table.mev.thorium.pdfs,    table.mev.egeo   );
table.mev.smeared.geonu{3}    = fcnsmearenergy(input, table, table.mev.potassium.e,   table.mev.potassium.pdfs,  table.mev.egeo   );

if flags.status.EstMenuEnergyCut
    input.ecut.value = 3.4; %MeV
    ei1 = fcnindex1(table.mev.e,input.ecut.value);
    ei = ei1:1:numel(table.mev.e);
    eig = ei1:1:uint32(table.mev.geov1(end));

    table.mev.smeared.fastneutron   = table.mev.smeared.fastneutron(:,ei);
    table.mev.smeared.accidental    = table.mev.smeared.accidental(:,ei);
    table.mev.smeared.cosmogenic    = table.mev.smeared.cosmogenic(:,ei);
    
    for i=1:numel(table.mev.smeared.geonu)
        a = table.mev.smeared.geonu{i};  table.mev.smeared.geonu{i}=a(:,eig); 
    end
    %table.mev.smeared.gpdfs        = table.mev.smeared.gpdfs(ei,ei);
    
    table.mev.e = table.mev.e(ei);
    table.mev.geov1 = 1:numel(eig);
    table.mev.ne = numel(table.mev.e);
    %table.mev.pdf0 = table.mev.pdf0(ei);
end


fprintf('Done (%.2fs)\n',toc)
end



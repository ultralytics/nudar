FileName = sprintf('%s KamLAND 80pc ML02 D1 CandidateID2 Trade Study',input.scenario);

reset(RandStream.getGlobalStream)
set(handles.GUI.textMCrun,'Visible','on');
nMC = 250;
nv = input.dValid.count;
startclock = clock;

n = numel(MC.systematic.true);
systematic.true = zeros(nMC,n);
systematic.est = zeros(nMC,n);
systematic.n1MC = zeros(nMC, numel(d(1).z.nallv));

rkr = fcnrange(d(1).positionECEF, input.reactor.IAEAdata.unique.ecef);  [rkr, j]=min(rkr);
p1 = input.reactor.IAEAdata.unique.ecef(j,:);
p2 = d.positionECEF;
dx = fcnvec2uvec(p2-p1);


rv = [2:60];
np = numel(rv);
pos = ones(np,1)*p1 + rv'*dx;

flags.status.ML0=1; flags.update.ML0=1;
for i=1:np
    
    d.positionECEF = pos(i,:);
    d.positionLLA = ecef2lla(d.positionECEF);
    d.detectordepth = -2000;
    d.position = fcnLLA2GoogleMapsXY(input, d.positionLLA);
    d.reactors = []; [r, dx] = fcnrange(d.positionECEF, [input.reactor.IAEAdata.unique.ecef; input.reactor.positionECEF]); d.reactors.udxecef=fcnvec2uvec(dx, r); d.reactors.r=r;
    d.kr = []; [r, dx] = fcnrange(d.positionECEF, input.reactor.IAEAdata.unique.ecef); d.kr.udxecef=fcnvec2uvec(dx, r); d.kr.r=r; d.kr.ni=numel(r);
    
    d = fcncleardtables(d, input);
    d = fcngetnonneutrinos(d, input, stable);
    d = fcnintegratecrust(d, stable, 1);
    [d.n, d.epdf, d.aepdf] = fcnmeanspectra(input, stable, d, 0);

    for iMC=1:nMC
        fprintf('\n\nStarting r=%.0fkm #%.0f\n',rv(i),iMC)
        [input, table] = fcnosctables(input, table, flags);
        input = fcnupdatefluxnoise(input, table, d, flags);
        d = fcnSingleDetector(d, table, input);
        [input, d] = fcnCreateValidDetectorList(input, d);
        
        [handles.ML0, MC] = fcnML0(input,handles,flags,d,stable);
        
        systematic.n1MC(iMC,:) = d.z.nallv;
        systematic.true(iMC,:) = MC.systematic.true;
        systematic.est(iMC,:) = MC.systematic.est;
        set(handles.GUI.textMCrun,'String',sprintf('%.0f',iMC)); drawnow
    end
    
    truesys(i,:) = mean(systematic.true);
    estsys(i,:) = std(systematic.true-systematic.est)./mean(systematic.true);
    nmean(i,:) = mean(systematic.n1MC);
    nstd(i,:) = std(systematic.n1MC);
end

%PLOT ERROR HISTOGRAMS AND 68PERCENTILES ----------------------------------
%fcnplotML0MCresults(input, table, flags, handles, p, [], systematic, d);

%SAVE ALL FIGURES TO FIG FILE ---------------------------------------------
fprintf('Saving Data... ')
input.ETOPO.ETOPO1_Ice_g = [];
save('-v6',[FileName '.mat'], 'nstd', 'nmean','truesys','estsys', 'rv');
fprintf('Done\nFiles saved as "%s"\n',FileName)

%PRINT TIMING INFORMATION TO WORKSPACE ------------------------------------
elapsed = etime(clock,startclock);
fprintf('%.0f MC Runs Completed in %.1fhrs (%.0fs), %.3fs per run.\n',nMC,elapsed/3600,elapsed,elapsed/nMC)










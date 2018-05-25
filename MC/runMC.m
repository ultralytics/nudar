if ~isfield(flags.status,'MC6')
    dstr = num2str(input.dValid.idx); dstr = [' D' dstr(~isspace(dstr))];
    cutstr = [' ' num2str(input.ecut.value) 'MeVcut'];
    candidatestr = [' CandidateID' num2str(input.ci) ''];
    
    if flags.status.ML4 && flags.status.ML2; eststr=' ML42';
    elseif flags.status.ML4 && flags.status.ML3; eststr=' ML43';
    elseif flags.status.ML0 && flags.status.ML2; eststr=' ML02';
    elseif flags.status.ML0 && flags.status.ML3; eststr=' ML03';
    else
        if flags.status.ML1; eststr=' ML1'; elseif flags.status.ML2; eststr=' ML2'; elseif flags.status.ML3; eststr=' ML3';  else  eststr=' NoEstimator'; end
    end
    
    nstr = [' ' num2str(input.MCrunCount) 'MCs'];
    vol = table.d(input.di).detector.volume;
    if input.dNoiseMultiplier==1 || (flags.status.ML1 || flags.status.ML2)
        snrstr='';
    else
        snrstr = ['x' sprintf('%0.4g',1/input.dNoiseMultiplier) 'SNR'];
    end
    volStr = [' ' table.d(input.di).name];
    rpstr = sprintf(' %gMWth',input.reactor.power*1E3);
    FileName = [input.scenario rpstr volStr eststr snrstr cutstr dstr candidatestr nstr];
    
    [FileName,PathName] = uiputfile('*.fig','Create a new file to save MC results to:',[cd '/MCRESULTS/' FileName]); %#ok<MCCD>
    if FileName(1)==0 || (flags.status.ML0==0 && flags.status.ML1==0 && flags.status.ML2==0 && flags.status.ML3==0 && flags.status.ML4==0)
        return
    elseif FileName(end-3)=='.'
        FileName = FileName(1:end-4);
    end
end

reset(RandStream.getGlobalStream)
%RandStream.setGlobalStream(RandStream('mt19937ar','Seed','shuffle'))

set(handles.GUI.textMCrun,'Visible','on');
newHandles = [];
nMC = input.MCrunCount;
nv = input.dValid.count;

input.ETOPO.ETOPO1_Ice_g = [];
p = zeros(input.nxy, input.nxy, input.nrp);
mlpoint = zeros(nMC,5);
if flags.status.ML4 || flags.status.ML0
    n = numel(MC.systematic.true);
    systematic.true = zeros(nMC,n);
    systematic.est = zeros(nMC,n);
end
n1MC = zeros(nMC, numel(d(1).z.nallv));

set(handles.GUI.figure1,'Pointer','watch')
startclock = clock;
h1 = [];
for iMC=1:nMC
    [input, table] = fcnosctables(input, table, flags);
    input = fcnupdatefluxnoise(input, table, d, flags);
    
    for j=1:input.dCount;
        d(j) = fcnSingleDetector(d(j), table, input);
        n1MC(iMC,:) = n1MC(iMC,:) + d(j).z.nallv./nv;
    end
    [input, d] = fcnCreateValidDetectorList(input, d);
    deleteh(h1)
    if flags.status.ML4
        [h1, MC] = fcnML4(input,handles,flags,d,stable);
    elseif flags.status.ML0   
        [h1, MC] = fcnML0(input,handles,flags,d,stable);
    else
        if flags.status.CRLB;  [h1, MC] = fcnCRLB(input,handles,flags,d,stable);  end
        if flags.status.ML1;   [h1, MC] = fcnML123(input,handles,flags,d,stable);  end
        if flags.status.ML2;   [h1, MC] = fcnML123(input,handles,flags,d,stable);  end
        if flags.status.ML3;   [h1, MC] = fcnML123(input,handles,flags,d,stable);  end
    end
    
    %SAVE -----------------------------------------------------------------
    if ~flags.status.ML0
        p = p + MC.p;
        mlpoint(iMC,:) = MC.mlpoint;
    end
    if flags.status.ML0 || flags.status.ML4
        systematic.true(iMC,:) = MC.systematic.true;
        systematic.est(iMC,:) = MC.systematic.est;
    end
    
    fprintf('Finished MC %.0f/%.0f\n\n',iMC,nMC);
    set(handles.GUI.textMCrun,'String',sprintf('%.0f',iMC)); drawnow
end
set(handles.GUI.figure1,'Pointer','arrow')

mlpoint = [mlpoint zeros(nMC,3)];
systematic.n1MC = n1MC;

%PLOT ERROR HISTOGRAMS AND 68PERCENTILES ----------------------------------
input.MCFileName = FileName;
if flags.status.ML0
    fcnplotML0MCresults(input, table, flags, handles, p, mlpoint, systematic, d);
else
    deleteh(h1)
    flags.upsample = 1;
    fcnplotMCresults(input, table, flags, handles, p, mlpoint, systematic, d);
end

%SAVE ALL FIGURES TO FIG FILE ---------------------------------------------
fprintf('Saving Figures... ')
fh = findall(0,'Type','figure'); %figure handles
v1 = fh~=handles.GUI.figure1;

hgsave(fh(v1),[PathName FileName '.fig'])
close(fh(v1));
fprintf('Done\n')

clear MC
elapsed = etime(clock,startclock);
MC.elapsedhours = elapsed/3600;
fprintf('Saving Data... ')
ne = numel(FileName);
input.ETOPO = [];
input.EGM = [];
save([PathName FileName '.mat'], 'p', 'mlpoint', 'input', 'flags', 'systematic','FileName','MC');
fprintf('Done\nFiles saved as "%s" in %s\n',FileName,PathName)

%PRINT TIMING INFORMATION TO WORKSPACE ------------------------------------
fprintf('%.0f MC Runs Completed in %.1fhrs (%.0fs), %.3fs per run.\n',nMC,elapsed/3600,elapsed,elapsed/nMC)










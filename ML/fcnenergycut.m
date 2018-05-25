function [npebr, npebr1s, d1] = fcnenergycut(input, flags, table, d1)
%npebr = number of background events to expect after cut
%nz0 = number of observed events after cut
%npe0 = number of reactor events to expect after cut, for use with rpscale

if ~isfield(d1,'epdf') || isempty(d1.epdf)
    [d1.n, d1.epdf, d1.aepdf] = fcnmeanspectra(input, table, d1, 0);
end

if ~isfield(d1,'est') || isempty(d1.est)
    [d1.est.r, dx] = fcnrange(d1.positionECEF, input.google.maps.ECEF); %ranges, 40,000x1
    d1.est.puvec = fcnvec2uvec(dx, d1.est.r);
    
    %RANGE-COUNT LOOKUP TABLE ------------------------------------------------
    [minr maxr] = fcnminmax(d1.est.r);
    nr = round(input.nxy*2);  dr=table.mev.r(2)-table.mev.r(1);
    r=linspace(max(minr-dr*2,table.mev.r(1)), maxr+dr*2, nr)';  
    ri = uint16(1:fcnindex1(table.mev.r, max(r)+10));  %max ri
    fs=interp1(table.mev.r(ri,:),table.mev.fs(ri,:), r);  s=fcnspec1s(table.mev.eall, r, [], 0, 1, 1, table.mev.pdf0*d1.dutycycle.all, fs);
    
    s.epdf=fcnsmearenergy(input, table, table.mev.eall, s.s, table.mev.e);  s.r=r;  s.n=sum(s.epdf,2)*table.mev.de;
    d1.est.urtable=s;
    
    fprintf('Building range count lookup table')
end

if flags.status.CRLB
    estunc = input.fluxnoise.systematic.mean(1:6);
    est = [1 1 1 1 1 1];
else
    est = input.fluxnoise.systematic.estimated(1:6);
    if any(est~=[1 1 1 1 1 1]); %using better estimates, reduce noise
        estunc = [0 0 0 0 0 0]; %post estimate systematic uncertainty
        %estunc = input.fluxnoise.systematic.mean.*[.99 .09 .91 1 1 1]; %post estimate systematic uncertainty
    else %leave noise unchanged
        estunc = input.fluxnoise.systematic.mean(1:6);
    end
end
d1.est.estunc = estunc;

n=d1.n;
npebr = (n.kr*est(1) + n.mantle*est(2) + n.crust*est(3) + n.fastneutron*est(4) + n.accidental*est(5) + n.cosmogenic*est(6));

npebr1svec = [    n.kr*est(1)*estunc(1)
    n.crust*est(3)*estunc(3)
    n.mantle*est(2)*estunc(2)
    n.fastneutron*est(4)*estunc(4)
    n.accidental*est(5)*estunc(5)
    n.cosmogenic*est(6)*estunc(6)
    n.krv.*input.fluxnoise.uncorrelated.meanperkrsite %statistical known reactor noise
    n.crust*input.fluxnoise.uncorrelated.mean(2)/sqrt(table.crust.all.n)
    n.allbackground*input.fluxnoise.uncorrelated.mean(3) ]; %detector uncertainty (i.e. fiducial volume)
ne = numel(npebr1svec);

d1.est.br1s    = norm(npebr1svec(1:ne-1)); %backgruond 1sigma only (no fiducial uncertainty)
npebr1svec(ne) = (npebr1svec(ne)^2 + (d1.est.br1s*input.fluxnoise.uncorrelated.mean(3))^2)^.5; %add in detector uncertainty affecting background uncertainty
d1.est.d1s     = npebr1svec(ne); %background and detector 1sigma

npebr1s = norm(npebr1svec);
d1.est.ML31.npebr1s = norm(npebr1s);
end
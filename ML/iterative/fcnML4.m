% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

function [newHandles, MC, d, input, flags] = fcnML4(input,handles,flags,d,table)
newHandles = []; MC = [];
if flags.status.ML4==0 || input.dValid.count<1
    deleteh(handles.ML4);
    return
end
fprintf('Running ML4...\n'); startclock = clock;
if input.dNoiseMultiplier>1
    flags.status.ML2=1;  flags.status.ML3=0;
else
    flags.status.ML2=0;  flags.status.ML3=1;
end
extent = input.google.maps.extent;
fns = input.fluxnoise.systematic;  fns.estimated=ones(size(fns.estimated));

A=[];  B=[];  Aeq=[];  Beq=[];
s=3;
LB = [extent(1) extent(3) input.rp1 max(1-fns.mean(1:6)*s,0) ];
UB = [extent(2) extent(4) input.rp2     1+fns.mean(1:6)*s    ];
for i = 1:input.dValid.count
    j = input.dValid.idx(i);
    [~, ~, d(j)] = fcnenergycut(input, flags, table, d(j));
    [d(j).est.ae1 d(j).est.e1]=fcnprob3(input, table, d(j), flags);
end

for n = 1
    if n==1
        maxpos=round([input.nxy input.nxy input.nrp]/2);  nm=1;
    else
        [newHandles, MC, d] = fcnML123(input,handles,flags,d,table); drawnow
        [~, maxpos]=MinimaMaxima3D(MC.p,0,0,300,1);  if isempty(maxpos);  [~, maxpos]=MinimaMaxima3D(MC.p,0,1,300,1);  end

        rmax = norm([input.nxy input.nxy input.nrp]*0.10); %10% spread allowed!
        v1 = (1:size(maxpos,1))';
        for i=v1'
            r1 = fcnrange(maxpos(i,:),maxpos(v1,:));
            v2 = r1>rmax | v1<=i;
            v1 = v1(v2);
        end
        nm=min(numel(v1),10);  v1=v1(1:nm);  maxpos=maxpos(v1,:); %limit to 10 points
        if nm==0;  deleteh(newHandles);  break;  end
    end
    
    vec1 = zeros(nm,16-4);
    fprintf('Running Optimizers...\n      f(x)   latitude  longitude   ur power       IAEA     mantle      crust      fastn accidental cosmogenic     allgeo        all\n')
    for j = 1:nm 
        lla = fcnGoogleMapsXY2LLA(input, flags, maxpos(j,[2 1]));
        x0 = [lla(1:2) input.rpVec(maxpos(j,3)) fns.estimated(1:6) input.osc.est.mu]; %[lat lng rp kr mantle crust fn acc cosm dm12 dm13 s2t12 s2t13]
        x0 = x0(1:9);
        fprintf('Starting:  '); fprintf('%10.3f ',addallgeo(fns, x0)); fprintf('\n')
        
        [x1, fx1] = fmincon(@(x) fcnML41(input,d,table,flags,x), x0, A, B, Aeq, Beq, LB, UB, [], input.optim.options); %[x1, fx1] = fminsearch(@(x) fcnML41(input,d,table,flags,x,1E-6), x0, options);
        
        x1 = addallgeo(fns, x1);
        vec1(j,:) = [fx1 x1];
        fprintf('%10.3f ',[fx1 x1]); fprintf('\n')
    end
    deleteh(newHandles);
    [~, i] = min(vec1(:,1));
    fns.estimated=vec1(i,5:16-4);  input.fluxnoise.systematic.estimated=fns.estimated;
end
[newHandles, MC, d] = fcnML123(input,handles,flags,d,table);

%SAVE----------------------------------------------------------------------
MC.systematic.true = [fns.rand,       input.osc.true.mu,  input.reactor.power];
MC.systematic.est  = [fns.estimated,  input.osc.est.mu,   vec1(1,4)];
fprintf(' Done ML4. (%.2fs)\n\n', etime(clock,startclock))
end

function x1 = addallgeo(fns, x1)
x1(10) = x1(5)*(1-fns.cf) + x1(6)*fns.cf; %allgeo
x1(11) = sum(fns.af.*x1(4:9)); %all
end

function [newHandles, MC, d, input, flags] = fcnML0(input,handles,flags,d,table)
newHandles = []; MC = [];
if flags.status.ML0==0 || input.dValid.count<1
    deleteh(handles.ML0);
    return
end
fprintf('Running ML0...\n'); startclock = clock;
if input.dNoiseMultiplier>1
    flags.status.ML2=1;  flags.status.ML3=0;
else
    flags.status.ML2=0;  flags.status.ML3=1;
end
fns = input.fluxnoise.systematic;  fns.estimated=ones(size(fns.estimated));

A=[];  B=[];  Aeq=[];  Beq=[];
o=table.osc; s=3;
LB = max([1-fns.mean(1:6)*s, o.u-o.sl*s,  0],0);
UB =     [1+fns.mean(1:6)*s, o.u+o.su*s,  6];
active = find([1 1 1 1 1 1 1 1 1 1 0]); %[1-kr 2-mantle 3-crust 4-fn 5-acc 6-cosm 7-dm12 8-dm13 9-s2t12 10-s2t13 11-georeactor];
for i = 1:input.dValid.count
    j = input.dValid.idx(i);
    [~, ~, d(j)] = fcnenergycut(input, flags, table, d(j));
    [d(j).est.ae1, d(j).est.e1]=fcnprob3(input, table, d(j), flags);
end
x0 = [fns.estimated(1:6) input.osc.est.mu 1]; 
fprintf('Optimizing...\n      f(x)       IAEA     mantle      crust      fastn accidental cosmogenic       dm12       dm13      s2t12      s2t13 georeactor\nStarting:  ');  fprintf('%10.3g ',x0);   fprintf('\n')

[x1, fx] = fmincon(@(x) fcnML01(input,d,table,flags,active,x0,x), x0(active), A, B, Aeq, Beq, LB(active), UB(active), [], input.optim.options);  x=x0;  x(active)=x1;
%[x1, fx] = fminsearch(@(x) fcnML01(input,d,table,flags,active,x0,x), x0(active));  x=x0;  x(active)=x1;
fprintf('%10.3g ',[fx x]); fprintf('\n')

y = addallgeo(fns, x);
fns.estimated=[x(1:6) y];  input.fluxnoise.systematic.estimated=fns.estimated;
input.osc.est.mu = x(7:10);

MC.systematic.true = [fns.rand,         1,       input.osc.true.mu];
MC.systematic.est  = [fns.estimated,    x(11),   input.osc.est.mu];
fprintf('True:      ');  fprintf('%10.3g ',[fns.rand(1:6), input.osc.true.mu, 1]);  fprintf('\n Done ML0. (%.2fs)\n', etime(clock,startclock))
end

function y = addallgeo(fns, x)
y(1) = x(2)*(1-fns.cf) + x(3)*fns.cf; %allgeo
y(2) = sum(fns.af.*x(1:6)); %all
end

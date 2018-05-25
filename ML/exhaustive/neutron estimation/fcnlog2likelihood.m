function L = fcnlog2likelihood( logL )
%protected conversion from log-likelihood to likelihood

v= logL(:);
i = ~isnan(v);
logL = logL - max(v(i));
L = exp(logL);

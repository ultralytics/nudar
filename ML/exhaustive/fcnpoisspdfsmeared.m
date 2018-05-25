function L = fcnpoisspdfsmeared(Oi, Ti0, sig)

if Oi>50
    Vi = Ti0 + sig^2;
    L = log(1./sqrt(2*pi*Vi))-(Oi-Ti0).^2./(2*Vi); %lognormal
else
    
    n2 = 100;
    npdfx = linspace(-3,3,n2);
    npdfy = normpdf(npdfx,0,1); npdfy = npdfy/sum(npdfy); %normalized normal
        
    L = zeros(size(Ti0));
    for j = 1:n2
        Ti = Ti0 + sig*npdfx(j);
        L = L + npdfy(j)*exp(Oi.*log(Ti) - Ti); %logpoiss
    end
    L = log(L) - gammaln(Oi+1);
    L = max(L, -1E64);
end

end


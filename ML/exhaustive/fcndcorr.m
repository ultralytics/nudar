% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

function [C, D] = fcndcorr(input, d)
%Count Covariance from one detector to another
%C = covariance matrix
%D = correlation matrix

C = ones(input.dValid.count);
for i = 1:input.dValid.count
    d1 = d(input.dValid.idx(i));   

    Bi = d1.n.allbackground; %mean background rate
    C(i,:) = C(i,:)*d1.est.br1s;
    C(:,i) = C(:,i)*d1.est.br1s;
    C(i,i) = C(i,i) + d1.est.d1s.^2 + Bi + Bi*.025; %Bi*.025 adds osc
end

if nargout>1
    D = ones(input.dValid.count);
    for i = 1:input.dValid.count
        D(:,i) = C(:,i)./(C(i,i)*diag(C)).^.5;
    end
end

end

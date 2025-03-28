% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

function L = fcnrpprior(input, flags, L)
%add reactor power prior log likelihood to existing likelihood matrix

if flags.status.EstMenuUseRPPriorEquation
    Pexp = input.reactor.power; %GW
    sPexp = .05/.3*Pexp; %GW
    for j = 1:input.nrp
        P = input.rpVec(j); %unknown reactor mean power
        L(:,j) = L(:,j) - (P-Pexp).^2/sPexp^2;
    end
end

end


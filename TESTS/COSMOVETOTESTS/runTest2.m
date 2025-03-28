% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

% 
% MCrunCount = 50;
% 
% vetovec = linspace(0,2500,MCrunCount);
% y = zeros(MCrunCount,1);
% for MCrun=1:MCrunCount
%     mcvar.dt = vetovec(MCrun);
%     updateDetectors
%     
%     flags.status.CRLB=1;
%     flags.update.CRLB=1;
%     
%     updatePlots
%     y(MCrun) = MCdata.CRLB.enclosedArea;
% end
% save somalia.mat vetovec y
    
load('somalia')
figure; plot(vetovec,y,'b.-'); xlabel('Veto Time (ms)'); ylabel('CE90 (km^2)'); title('Cosmogenic Veto time Vs CRLB Marginal 90% Confidence Area'); hold on
load('srilanka')
plot(vetovec,y,'r.-')
load('dakar')
plot(vetovec,y,'g.-')
  


x = [250 500 750 1000 1250 1500 1750 2000 2250 2500 2750];
y1 = [295260 142408 90668 69897 63825 65103 63171 66323 67645 72003 74922]; %marginal
y2 = [181380 95447 58276 39132  35951 33597 32537 35413 35616 38609 41470]; %conditional
y3 = [86132 38421 21333 15177  13635 13642 13342 14201 14362 15738 16762]; %3D
plot(x,y1,'b.-','MarkerSize',20)

%dakar
x = [1800 2500];
y1 = [4923 13251];
plot(x,y1,'g.-','MarkerSize',20)

%sri lanka
x = [1800 2500];
y1 = [9648 12126];
plot(x,y1,'r.-','MarkerSize',20)

legend('Somalia Marginal CRLB','Sri Lanka Marginal CRLB','Dakar, Senegal Marginal CRLB','Somali MC','Sri Lanka MC','Dakar MC') 
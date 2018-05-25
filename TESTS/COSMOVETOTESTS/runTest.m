
%     MCrunCount = 30;
%     
%     vetovec = linspace(0,600,MCrunCount);
%     y = zeros(MCrunCount,1);
%     for MCrun=1:MCrunCount
%         mcvar.dt = vetovec(MCrun)
%         updateDetectors
%         
%         flags.status.CRLB=1;
%         flags.update.CRLB=1;
%         
%         updatePlots
%         y(MCrun) = MCdata.CRLB.enclosedArea;
%     end
     
load('vetotrade1')
figure; plot(vetovec,y,'b.-'); xlabel('Veto Time (ms)'); ylabel('CE90 (km^2)'); title('Cosmogenic Veto time Vs CRLB Marginal 90% Confidence Area'); hold on
load('vetotrade2')
plot(vetovec,y,'r.-')

x = [250 500 750 1000 1250 1500 1750 2000 2250 2500 2750];
y1 = [295260 142408 90668 69897 63825 65103 63171 66323 67645 72003 74922]; %marginal
y2 = [181380 95447 58276 39132  35951 33597 32537 35413 35616 38609 41470]; %conditional
y3 = [86132 38421 21333 15177  13635 13642 13342 14201 14362 15738 16762]; %3D
plot(x,y1,'b.-','MarkerSize',30)

% %dakar
% x = [1800 2500];
% y1 = [4923 13251];
% plot(x,y1,'g.-','MarkerSize',30)
% 
% %sri lanka
% x = [1800 2500];
% y1 = [9648 12126];
% plot(x,y1,'r.-','MarkerSize',30)

%plot(x,y2,'g.-','MarkerSize',30)
%plot(x,y3,'m.-','MarkerSize',30)
legend('Far Range Marginal CRLB','Short Range Marginal CRLB','Far Range Marginal MCs','Far Range Conditional MCs','Far Range 3D MCs (km^2GW)')   
%save vetotrade2.mat vetovec y
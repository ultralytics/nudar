% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

clc
clear all
close all

nmc = 2E4;
np = 100;
xout = zeros(np,1);
fvu = linspace(0,10,np); %fiducial volume uncertainty
for i = 1:np
    x = ones(nmc,1)*[1500 400] + [randn(nmc,1)*1500*.20 randn(nmc,1)*400*.03];    
    x = max(x,0);
    x = x.*((1+randn(nmc,1)*fvu(i)/100)*[1 1]);
    cx = corr(x);
    xout(i) = cx(1,2);
end

figure; plot(fvu,xout);
hold on

for i = 1:np
    x = ones(nmc,1)*[1500 400] + [randn(nmc,1)*1500*.20/10 randn(nmc,1)*400*.03];
    x = max(x,0);
    x = x.*((1+randn(nmc,1)*fvu(i)/100)*[1 1]);
    %cov(x)
    cx = corr(x);
    xout(i) = cx(1,2);
end

plot(fvu,xout,'r');
axis tight
xlabel('Fiducial Volume Uncertainty (%)')
ylabel('Geo-IAEA Error Correlation')
title('Geo-IAEA Error Correlation')
legend('A-Priori (before ML42)','Posteriori (after ML42)')
grid on

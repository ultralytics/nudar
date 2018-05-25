clc
clear all
close all

nmc = 1E4;
np = 100;
xout = zeros(np,1);
fvu = linspace(0,30,np); %fiducial volume uncertainty
means = ones(nmc,1)*[1500 400];
for i = 1:np
    gains = 1+[randn(nmc,1)*.20 randn(nmc,1)*.03];
    x = [gains.*means gains.*means];    
    x = max(x,0);
    x = x.*([(1+randn(nmc,1)*fvu(i)/100)*[1 1], (1+randn(nmc,1)*fvu(i)/100)*[1 1]]);
    x = [x(:,1)+x(:,2), x(:,3)+x(:,4)];
    cx = corr(x);
    xout(i) = cx(1,2);
end

figure; plot(fvu,xout);
hold on

for i = 1:np
    gains = 1+[randn(nmc,1)*.02 randn(nmc,1)*.03];
    x = [gains.*means gains.*means];    
    x = max(x,0);
    x = x.*([(1+randn(nmc,1)*fvu(i)/100)*[1 1], (1+randn(nmc,1)*fvu(i)/100)*[1 1]]);
    x = [x(:,1)+x(:,2), x(:,3)+x(:,4)];
    cx = corr(x);
    xout(i) = cx(1,2);
end

plot(fvu,xout,'r');
axis tight

ylabel('Detector1-Detector2 Error Correlation')
title('Detector-Detector Count Correlation')
legend('A-Priori (before ML42)','Posteriori (after ML42)')
grid on
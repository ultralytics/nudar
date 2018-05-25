clc
clear all
close all
digits(5) %show a max of 5 digits
%http://en.wikipedia.org/wiki/Linear_least_squares
syms xr yr GWr
syms x1 y1 m1 x2 y2
syms xhat1 yhat1 zhat1 N1 N2
syms dMeV MeV
syms sigx1hat sigy1hat plotTime

rhat = sqrt(xhat1^2+yhat1^2);

dx = (xr-x1);
dy = (yr-y1);

r1 = sqrt(dx^2+dy^2);
r2 = sqrt((xr-x2)^2+(yr-y2)^2);

f1 = .59+.41*cos(.2032*r1/MeV);
f2 = .59+.41*cos(.2032*r2/MeV);

F1 = acos( (xhat1*dx+yhat1*dy)/(rhat*r1) ); %rvec
F2 = 17/20440*(MeV-1.43)^2*exp(-(.3125*MeV+.25)^2)*m1*f1*GWr*plotTime/r1^2*dMeV - N1; %flux
%F3 = ((MeV-1.43)^2*exp(-(.3125*MeV+.25)^2))/((MeV-1.43)^2*exp(-(.3125*MeV+.25)^2)*f1)*N1*r1^2 - ((MeV-1.43)^2*exp(-(.3125*MeV+.25)^2))/((MeV-1.43)^2*exp(-(.3125*MeV+.25)^2)*f2)*N2*r2^2; %triangulation




A = [  diff(F1,N1)=0   diff(F1,xhat1)       diff(F1,yhat1)
       diff(F2,N1)=-1  diff(F2,xhat1)=0     diff(F2,yhat1)=0     
       diff(F3,N1)     diff(F3,xhat1)=0     diff(F3,yhat1)=0     diff(F3,N2) ];
 
B = [  diff(F1,xr)     diff(F1,yr)      diff(F1,GWr)=0
       diff(F2,xr)     diff(F2,yr)      diff(F2,GWr)
       diff(F3,xr)     diff(F3,yr)      diff(F3,GWr)=0      ];

B(2,1) = -88519/2555000000*(MeV-143/100)^2*exp(-(5/16*MeV+1/4)^2)*m1*sin(127/625*(xr^2-2*xr*x1+x1^2+yr^2-2*yr*y1+y1^2)^(1/2)/MeV)/(xr^2-2*xr*x1+x1^2+yr^2-2*yr*y1+y1^2)^(3/2)/MeV*(2*xr-2*x1)*GWr*plotTime*dMeV-17/20440*(MeV-143/100)^2*exp(-(5/16*MeV+1/4)^2)*m1*(59/100+41/100*cos(127/625*(xr^2-2*xr*x1+x1^2+yr^2-2*yr*y1+y1^2)^(1/2)/MeV))*GWr*plotTime/(xr^2-2*xr*x1+x1^2+yr^2-2*yr*y1+y1^2)^2*dMeV*(2*xr-2*x1);
B(2,2) = -88519/2555000000*(MeV-1.43)^2*exp(-(.3125*MeV+.25)^2)*m1*sin(.2032*e2/MeV)/e1^1.5/MeV*(2*yr-2*y1)*GWr*plotTime*dMeV-17/20440*(MeV-1.43)^2*exp(-(.3125*MeV+.25)^2)*m1*(.59+.41*cos(.2032*e2/MeV))*GWr*plotTime/e1^2*dMeV*(2*yr-2*y1);
B(2,3) = 17/20440*(MeV-1.43)^2*exp(-(.3125*MeV+.25)^2)*m1*(.59+.41*cos(.2032*e2/MeV))*plotTime/e1*dMeV;

R = diag([N1 sigx1hat^2 sigy1hat^2]);
Re = A*R*A';
We = inv(Re);
N=B'*We*B;
S=inv(N);
f = [-F1; -F2; -F3 ];
t = B'*We*f;
D = S*t;

v=R*A'*We*f;
Phi=v'*inv(R)*v;













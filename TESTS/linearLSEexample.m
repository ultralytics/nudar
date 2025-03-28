% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

clc
clear all
close all
%http://en.wikipedia.org/wiki/Linear_least_squares
syms B1 B2 fcn e1 e2 e3 e4

e1 = B1+1*B2-6;
e2 = B1+2*B2-5;
e3 = B1+3*B2-7;
e4 = B1+4*B2-10;

fcn = e1^2+e2^2+e3^2+e4^2;

diff(fcn,B1);
diff(fcn,B2);



X = [1     1
     1     2
     1     3
     1     4]
y = [6
     5
     7
     10]
B = inv(X'*X)*X'*y; %B1 = 3.5, B2 = 1.4
% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

h=fig(2,2);

axes(h(1))
x = linspace(1E-6,.15,1000);  dx=x(2)-x(1);
y1 = pdf('norm',x,0.025,.007);
plot(x,y1,'r')
title('Fogli 2011'); xlabel('sin^2(\theta_{13})')


axes(h(2))
y2 = pdf('norm',x,0.092,.017);
plot(x,y2,'b')
title('Daya Bay 2012'); xlabel('sin^2(2\theta_{13})')

axes(h(3))
x2 = asin(x.^.5);
plot(x2,y1,'r'); hold on
x3 = asin(x.^.5)./2;
plot(x3,y2,'b')
title('theta_{13} uncertainty'); xlabel('theta_{13}')



axes(h(4))
plot(x,y1,'r'); hold on
x4 = sin(x3).^2;
y1i = interp1(x4,y2,x,'linear');  y1i=y1i./sum(y1i(~isnan(y1i)))/dx;
plot(x,y1i,'b')
y3 = (y1i.*y1); y3=y3./sum(y3(~isnan(y3)))/dx;
plot(x,y3,'g')
legend('Fogli 2011 {\bf(\mu=0.025, \sigma=0.007)}','Daya Bay 2012 {\bf(\mu=0.0236, \sigma=0.00446)}','Combined {\bf(\mu=0.02399, \sigma=0.00377)}')
xlabel('sin^2(\theta_{13})')
axis([0 .05 0 140])

fcnfontsize(8)
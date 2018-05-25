clc
clear all
close all

u1 = 1800; s1 = 200;
u2 = 1300; s2 = 400;

np = 100;

x1 = linspace(0, 2700, np); dx1 = x1(2)-x1(1);
y1 = normpdf(x1,u1,s1);
y2 = normpdf(x1,u2,s2);

set(figure,'Position',[10 40 800 600])

% subplot(2,2,1); plot(x1,y1); hold on; plot(x1,y2,'r');
% legend('pdf_1','pdf_2'); xlabel('Count'); ylabel('density')

x1mat = ones(np,1)*x1 + (ones(np,1)*x1)';
subplot(2,2,1);
pcolor(x1,x1,x1mat); shading flat; xlabel('N_1'); ylabel('N_2'); axis square; colorbar
title('Conditional Count')

sxy = 1.0779e+005/1.4;
C = [s1^2     sxy
    sxy       s2^2];

i = 1; j = 2;
cc = C(i,j)/sqrt(C(i,i)*C(j,j));

[X, Y] = meshgrid(x1,x1);
p = fcnmultinormpdf([reshape(X,np^2,1) reshape(Y,np^2,1)] , [u1 u2], C);
p = reshape(p,np,np);

subplot(2,2,2);
pcolor(x1,x1,p); shading flat; xlabel('N_1'); ylabel('N_2'); axis square; colorbar
title(sprintf('Bayesian Prior p(theta)\nCorrelation Coeff: %.3f' ,cc))


%COUNT
np2 = 200;
cv = round(linspace(1,5000,np2));
pdf1 = zeros(np2,1);
pdf2 = pdf1;
pdf3 = pdf1;
for i = 1:np2
    c = cv(i);
    pdf1(i) = normpdf(c,u1+u2,sqrt(u1+u2+s1^2+s2^2));
    pdf2(i) = sum(sum(poisspdf(c, x1mat).*p))*dx1*dx1;
    pdf3(i) = poisspdf(c,u1+u2);
end

subplot(2,1,2)
plot(cv,pdf1,'r'); hold on; plot(cv,pdf2,'g'); plot(cv,pdf3,'b');
legend('Linear Approximation','Compound Distribution','Poisson Distribution')
xlabel('Measured Count'); ylabel('p(z_n|\theta)')
set(gca,'YLim',[0 max([pdf1' pdf2'])*1.3])
title('Comparison')




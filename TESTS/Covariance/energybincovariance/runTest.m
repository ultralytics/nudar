% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

clc
load zn.mat

c = cov(zn);
[r,p] = corrcoef(zn);
x = table.mev.e(1:930);

s = std(zn);
c2 = s'*s;

figure; pcolor(x,x,c2); shading flat; colorbar; xlabel('MeV'); ylabel('MeV'); set(gca,'Ydir','reverse','xaxislocation','top')
title('Count Error Covariance Matrix'); axis equal tight

figure; pcolor(x,x,log(c)); shading flat; colorbar; xlabel('MeV'); ylabel('MeV'); set(gca,'Ydir','reverse','xaxislocation','top')
title('Count Error Covariance Matrix LOGSPACE'); axis equal tight

figure; pcolor(x,x,r); shading flat; colorbar; xlabel('MeV'); ylabel('MeV'); set(gca,'Ydir','reverse','xaxislocation','top')
title('Count Error Correlation Matrix'); axis equal tight

figure; pcolor(x,x,p); shading flat; colorbar; xlabel('MeV'); ylabel('MeV'); set(gca,'Ydir','reverse','xaxislocation','top')
title('Count Error Correlation p-Values, "Significance"'); caxis([0 0.05]); axis equal tight
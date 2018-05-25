function [] = fcnPlotSpectra(input, table); tic
maxRange = 10; %km
F=griddedInterpolant(table.mev.r,1:numel(table.mev.r),'nearest'); ir=F(maxRange);

nr = numel(ir);
r = table.mev.r(ir);
r3 = linspace(table.mev.r(1),max(r),1000);

ha=fig(2,3,1.5);
standardDev = table.d(input.di).Estd(:,input.ci);
x = (2:1:11)';
k0=.10;  
k0=fminsearch(@(k) sum((k.*sqrt(x-.7823)-standardDev).^2), k0); %solve for least squares

%URANIUM ------------------------------------------------------------------
e2 = 3.6; %mev
s = table.mev.uranium;
pdfsy = [s.pdfs(ir,:) zeros(nr,numel(s.e(numel(s.e)):s.de:e2)-1)];
pdfsx = s.e:s.de:e2;
pdfsxi = 1.8:.005:e2;
pdfsy2 = fcnsmearenergy(input, table, pdfsx, pdfsy, pdfsxi);
pdfsy3 = interp1(r,pdfsy,r3,'*linear');

sca(ha(1))
pcolor(r3,pdfsx,pdfsy3'); shading flat; xyzlabel('L (km)','E_\nu (MeV)')
title('^{238}U Spectrum');
sca(ha(4))
pcolor(r,pdfsxi,pdfsy2'); shading flat; xyzlabel('L (km)','E_\nu (MeV)')
title([sprintf('%.1f%%',k0*100) 'E^{-1/2} Smeared ^{238}U  Spectrum']);

%THORIUM ------------------------------------------------------------------
s = table.mev.thorium;
pdfsy = [s.pdfs(ir,:) zeros(nr,numel(s.e(numel(s.e)):s.de:e2)-1)];
pdfsx = s.e:s.de:e2;
pdfsxi = 1.8:.005:e2;
pdfsy2 = fcnsmearenergy(input, table, pdfsx, pdfsy, pdfsxi);
pdfsy3 = interp1(r,pdfsy,r3,'*linear');

sca(ha(2))
pcolor(r3,pdfsx,pdfsy3'); shading flat; xyzlabel('L (km)','E_\nu (MeV)')
title('^{232}Th  Spectrum');
sca(ha(5))
pcolor(r,pdfsxi,pdfsy2'); shading flat; xyzlabel('L (km)','E_\nu (MeV)')
title([sprintf('%.1f%%',k0*100) 'E^{-1/2} Smeared ^{232}Th Spectrum']);


%REACTOR ------------------------------------------------------------------
ei = 1:700;
rvec = ones(size(r));
s = fcnspec1s(table.mev.e(ei), rvec, [], 1, 1, 1, table.mev.pdf0(ei), fcnspec1f(r, table.mev.e(ei))); %true spectrum
%s.s = bsxfun(@times,s.s,1./r.^2);

pdfsy = s.s;
pdfsx = table.mev.e; pdfsx = pdfsx(1:700);
pdfsxi = 1.8:.005:table.mev.e(max(ei));
pdfsy2 = fcnsmearenergy(input, table, pdfsx, pdfsy, pdfsxi);
pdfsy3 = interp1(r,pdfsy,r3,'*linear');

sca(ha(3))
pcolor(r3,pdfsx,pdfsy3'); shading flat; xyzlabel('L (km)','E_\nu (MeV)')
title('Reactor Spectrum');
sca(ha(6))
pcolor(r,pdfsxi,pdfsy2'); shading flat; xyzlabel('L (km)','E_\nu (MeV)')
title([sprintf('%.1f%%',k0*100) 'E^{-1/2} Smeared Reactor Spectrum']);
fcntight(ha)


%ENERGY RESOLUTION PLOTS
ha=fig(1,2);
sca(ha(1))
standardDev = table.d(input.di).Estd(:,input.ci);
x = (2:1:11)';
x2 = linspace(1.8,11,100);
k0=.10;  
k=fminsearch(@(k) sum((k.*sqrt(x-.7823)-standardDev).^2), k0); %solve for least squares
plot(x,standardDev,'r.',x2,k.*sqrt(x2-.8),'b-','MarkerSize',15,'LineWidth',1);
set(gca,'XTick',x)
axis([min(x2) max(x2) 0 max(standardDev)*2])
xyzlabel('E_{vis} (MeV)','E 1\sigma (MeV)')
title(sprintf('E resolution, Di %.0f, Ci %.0f, LS Fit k=%.3f', input.di, input.ci, k))
legend('MC Results',[sprintf('%.3f',k) 'E_{vis}^{1/2} LS Fit']); legend boxoff

sca(ha(2))
y = table.d(input.di).Ebias(:,input.ci);
errorbar(x,y,standardDev,'.-','Color',[1 .6 .6],'MarkerSize',15,'MarkerEdgeColor',[1 0 0],'LineWidth',1);
set(gca,'XTick',x)
axis tight
set(gca,'Xlim',[min(x2) max(x2)])
xyzlabel('E_{vis} (MeV)','E error (MeV)')
title(sprintf('E error, Di %.0f, Ci %.0f', input.di, input.ci))
legend('MeV'); legend boxoff
end
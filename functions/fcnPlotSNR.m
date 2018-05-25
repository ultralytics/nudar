function [  ] = fcnPlotSNR(input, flags, table, d)

%FIGURE 2

set(figure,'Position',[10 40 500 500])
plot(table.mev.e, table.mev.cf); xlabel('E_{\nu} (MeV)','Interpreter','tex'); ylabel('Passing %'); axis([2 11 0 1]); title('Candidate Fraction')

set(figure,'Position',[10 40 500 800])
e = 2:11;
u = table.d(input.di).rVecMag(:,input.ci);
s = table.d(input.di).rVecStd(:,input.ci);
snr = u./s;

subplot(3,1,1)
bar(e,u,.8,'EdgeColor',[.7 .7 .7],'FaceColor','b'); ylabel('\mu (mm)'); axis tight; xlabel('E_{\nu} (MeV)','Interpreter','tex')
title({'Direction Vector Magnitude \mu',sprintf('Detector Type %.0f, Candidate Critera %.0f', input.di, input.ci)})
fcncontextmenuexpand(gca)

subplot(3,1,2)
bar(e,s,.8,'EdgeColor',[.7 .7 .7],'FaceColor','b'); ylabel('1\sigma (mm)'); axis tight; xlabel('E_{\nu} (MeV)','Interpreter','tex')
title({'Direction Vector 1\sigma Standard Deviation Per Axis', sprintf('Detector Type %.0f, Candidate Critera %.0f', input.di, input.ci)})
fcncontextmenuexpand(gca)

subplot(3,1,3)
bar(e,snr,.8,'EdgeColor',[.7 .7 .7],'FaceColor','b'); ylabel('SNR'); axis tight; xlabel('E_{\nu} (MeV)','Interpreter','tex')
title(sprintf('Direction Vector SNR\nDetector Type %.0f, Candidate Critera %.0f', input.di, input.ci))
fcncontextmenuexpand(gca)

%FIGURE 1
set(figure,'Position',[530 40 1000 600])

nv = input.dValid.count;
if nv==0
    snr = mean(table.d(input.di).rVecMag(:,input.ci)./table.d(input.di).rVecStd(:,input.ci))/input.dNoiseMultiplier;
else
    snr = 0;
    for iv = 1:nv
        i = input.dValid.idx(iv); d1=d(i);
        [~, ~, d1] = fcnenergycut(input, flags, table, d1);
        d1 = fcnsnr(input, table, d1);
        snr = snr + d1.snr.val/nv;
    end
end

n = 3000;
ct1 = linspace(-1,1,n);
str = {'baseline','10X improvement','20X improvement','30X improvement'};
colors = {'k','r','g','b'};
snr = [1 10 20 30]*snr;

theta2 = linspace(0,180,n);
ct2 = cosd(theta2);

h2 = subplot(122); hold on
h1 = subplot(121); hold on
for i = 1:4
    snr1 = snr(i);
    y1 = fcnthetapdf(snr1, ct1);
    y2 = fcnthetapdf(snr1, ct2);
    
    plot(h1, ct1,y1,colors{i},'LineWidth',1); 
    text(ct1(n),y1(n),sprintf('%s\nSNR=%.3f',str{i},snr1),'HorizontalAlignment','Left','VerticalAlignment','Cap','fontsize',8)
    
    plot(h2, theta2, y2, colors{i},'LineWidth',1); 
end
xlabel(h1, 'cos\theta')
ylabel(h1, 'p(cos\theta)')
title(h1, sprintf('Smeared Angular Probability\nDetector Type %.0f, Candidate Critera %.0f', input.di, input.ci))
pos = get(h1,'Position');
set(h1,'Position',pos.*[1 1 .9 1])
fcncontextmenuexpand(h1)

xlabel(h2, '\theta (deg)')
ylabel(h2, 'p(\theta)')
title(h2, sprintf('Smeared Angular Probability\nDetector Type %.0f, Candidate Critera %.0f', input.di, input.ci))
axis(h2,'tight')
fcncontextmenuexpand(h2)
end


% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

function [] = fcnContextPlotEnergySpace(input, flags, table, d1, ~)
evec = table.mev.e -.7823;
%if ~isfield(d1,'epdf') || isempty(d1.epdf)
    [d1.n, d1.epdf, d1.aepdf] = fcnmeanspectra(input, table, d1, 0);
%end
n=d1.n;
epdf=d1.epdf;
de = table.mev.de;
iaeau = input.reactor.IAEAdata.unique;


%FIGURE 2 -----------------------------------------------------------------
ha=fig(2,3,1,1.2);
sca(ha(1));
Y = [epdf.accidental', epdf.fastneutron', epdf.cosmogenic', epdf.crustv(1,:)', epdf.crustv(2,:)', epdf.mantlev(1,:)', epdf.mantlev(2,:)', epdf.kr', epdf.ur'];
h = area(evec,Y);
set(h,'EdgeColor','none')
set(h(1),'FaceColor','k')
set(h(2),'FaceColor','c')
set(h(3),'FaceColor','m')
set(h(4),'FaceColor','g')
set(h(5),'FaceColor',[.7 1 .7])
set(h(6),'FaceColor','b')
set(h(7),'FaceColor',[.7 .7 1])
set(h(8),'FaceColor','y')
set(h(9),'FaceColor','r')
axis tight

labels = cell(9,1);
p = d1.n.allv./sum(d1.n.allv)*100;
order = [8 7 9 3 4 5 6 2 1];
for i = 1:9
    j=order(i);
    labels{i} = sprintf('%0.0f%% %s, %0.1f/yr', p(j), d1.n.allvlabels{j}, d1.n.allv(j));
end
hl1=legend(labels,'FontSize',10,'FontName','Arial','TextColor',[0 0 0]); legend boxoff

plot([1 1]*input.ecut.value-.7823, [0 1], '-', 'LineWidth', 2, 'Color', [1 1 1]*.6)
ei = max(fcnindex1(table.mev.e,1.8:.01:11),1);
ylim1=[0 max(sum(Y(ei,:),2))];  xlim1=[input.ecut.value 7.9]-.7823;
set(gca,'YLim',ylim1,'XLim',xlim1)
title(sprintf('Detector %.0f, %.2fMeV(visible) energy cut\n%.0fMWE, %.0f%% duty cycle, %.0f events/yr', d1.number, input.ecut.value-.7823, d1.detectordepth, d1.dutycycle.all*100, d1.n.all))


sca(ha(2))
np=10;
[~, i] = sort(d1.n.krv,1,'descend');
ae = d1.aepdf.kr(i,:);
ae = [ae(1:np,:); sum(ae(np+1:end,:),1)]; %ae=ae(end:-1:1,:); i=i(10:-1:1);
nae = sum(ae,2)*de;
h = area(evec,ae');
set(h,'EdgeColor','w')
axis tight
labels = cell(np+1,1);
for j = 1:np
    labels{j} = sprintf('%.0f/yr %s %s, %.1fGWth, %.0fkm', nae(j), iaeau.sitename{i(j)}, iaeau.country{i(j)}, iaeau.GWth(i(j)), d1.reactors.r(i(j)));
    labels{j} = strrep(labels{j},', REPUBLIC OF','');
end
labels{np+1} = sprintf('%.0f/yr %s', nae(np+1), 'ALL OTHER KNOWN REACTORS');
title('by Site')
set(gca,'YLim',ylim1,'XLim',xlim1)
legend(labels,'FontSize',10,'FontName','Arial','TextColor',[0 0 0],'Location','NorthWest'); legend boxoff
set(hl1,'FontSize',10,'FontName','Arial','TextColor',[0 0 0])

sca(ha(3))
[i, c, nae, ae] = sortcountries(iaeau,d1); np=numel(c);
h = area(evec,ae');
set(h,'EdgeColor','w')
axis tight
labels = cell(np,1);
for j = 1:np
    labels{j} = sprintf('%.0f/yr %s', nae(j), c{j});
    labels{j} = strrep(labels{j},', REPUBLIC OF','');
    set(h(j),'FaceColor',fcndefaultcolors(j))
end
title('by Country')
set(gca,'YLim',ylim1,'XLim',xlim1)
legend(labels,'FontSize',10,'FontName','Arial','TextColor',[0 0 0],'Location','NorthWest'); legend boxoff
set(hl1,'FontSize',10,'FontName','Arial','TextColor',[0 0 0])

sca(ha(4))
plot(evec,epdf.accidental/sum(epdf.accidental)/de,'k','LineWidth',2); hold on
plot(evec,epdf.fastneutron/sum(epdf.fastneutron)/de,'c','LineWidth',2); 
plot(evec,epdf.cosmogenic/sum(epdf.cosmogenic)/de,'m','LineWidth',2);
plot(evec,epdf.crustv(1,:)/sum(epdf.crustv(1,:))/de,'g','LineWidth',2);
plot(evec,epdf.crustv(2,:)/sum(epdf.crustv(2,:))/de,'Color',[.7 1 .7],'LineWidth',2);
plot(evec,epdf.mantlev(1,:)/sum(epdf.mantlev(1,:))/de,'b','LineWidth',2);
plot(evec,epdf.mantlev(2,:)/sum(epdf.mantlev(2,:))/de,'Color',[1 .7 .7],'LineWidth',2); 
plot(evec,epdf.kr/sum(epdf.kr)/de,'Color',[1 .9 0],'LineWidth',2); 
plot(evec,epdf.ur/sum(epdf.ur)/de,'r','LineWidth',2);
set(gca,'YLim',[0 1.25],'XLim',[input.ecut.value 7.9]-.7823)
labels = d1.n.allvlabels(order); %{'Accidental','Fast Neutrons','Cosmogenic','Crust 238U','Crust 232TH','Mantle 238U','Mantle 232TH','\Sigma Known Reactors',sprintf('Unknown Reactor (r=%.0fkm)',d1.range)};
legend(labels,'FontSize',10,'FontName','Arial','TextColor',[0 0 0]); legend boxoff
xyzlabel('E_{vis} (MeV)','p(E_{vis})')
title('Normalized Spectra')
plot([1 1]*input.ecut.value-.7823, [0 1], '-', 'LineWidth', 2, 'Color', [1 1 1]*.6)

sca(ha(5))
cmPerkm = 100000;
x = linspace(table.mev.r(1),table.mev.r(end),1000)'; dx = x(2)-x(1);

ri          = d1.crust.ri;
sa          = (1/cmPerkm^2)./d1.crust.r.^2; %solid angle
npe         = [table.mev.uranium.ns(ri).*d1.crust.flux(:,1).*sa  table.mev.thorium.ns(ri).*d1.crust.flux(:,2).*sa]*d1.dutycycle.all;
y           = accumarray(fcnindex1(x,d1.crust.r), sum(npe,2), size(x));
pdfy1 = y/sum3(y)/dx;       cdfy1 = cumsum(pdfy1)*dx;

ri          = d1.mantle.ri;
sa          = d1.mantle.sa;
npe         = [table.mev.uranium.ns(ri).*table.mantle.flux(:,1).*sa  table.mev.thorium.ns(ri).*table.mantle.flux(:,2).*sa]*d1.dutycycle.all;
y           = accumarray(fcnindex1(x,d1.mantle.r), sum(npe,2), size(x));
pdfy2 = y/sum3(y)/dx;       cdfy2 = cumsum(pdfy2)*dx;

plot(x,pdfy1,'g'); plot(x,pdfy2,'b'); ylabel('pdf'); title('geo\nu flux vs range'); axis tight; set(gca,'YLim',[0 .00025]); legend('Crust','Mantle')
sca; plot(x,cdfy1,'g');plot(x,cdfy2,'b'); ylabel('cdf'); title('geo\nu cumulative flux vs range'); axis tight; legend('Crust','Mantle','Location','best')

xyzlabel(ha(1:4),'E_{vis} (MeV)','#/MeV'); ylabel(ha(4),'pdf')
fcngrid(ha,'on'); xyzlabel(ha(5:6),'range from detector (km)')
%fcnlinewidth(2)
end


function [J, c, nae, ae] = sortcountries(iaeau,d1)
[c, ~, J] = unique(iaeau.country);
nae = accumarray(J,d1.n.krv);
ae = fcnaccumrows(d1.aepdf.kr,J);
[nae, i]=sort(nae,'descend');
c = c(i);  ae=ae(i,:);

n=6;
nae = [nae(1:n); sum(nae(n+1:end))];
ae =  [ae(1:n,:); sum(ae(n+1:end,:))];
c = c(1:n); c{n+1} = 'All OTHERS';
end
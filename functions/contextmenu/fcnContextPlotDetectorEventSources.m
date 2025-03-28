% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

function [] = fcnContextPlotDetectorEventSources(input, flags, table, d1, xy)
[~, ~, d1] = fcnenergycut(input, flags, table, d1);

%PLOT PIE CHART OF NEUTRINO SOURCES
f1 = figure; set(f1,'Position',[10 50 1000 600]);
subplot(122)
p = d1.n.allv./d1.n.all*100;
order = 1:9;

pie(d1.n.allv(order)+eps, [1 0 0 0 0 0 0 0 0]);
ch = get(gca,'Children');
set(ch(18),'FaceColor','r')
set(ch(16),'FaceColor','y')
set(ch(14),'FaceColor','g')
set(ch(12),'FaceColor','g')
set(ch(10),'FaceColor','b')
set(ch(8),'FaceColor','b')
set(ch(6),'FaceColor','c')
set(ch(4),'FaceColor','k')
set(ch(2),'FaceColor','m')

%SUBPLOT2
labels = cell(9,1);
for i = 1:9
    labels{i} = sprintf('%s  (%0.0f%% - %0.3f/yr)',d1.n.allvlabels{i}, p(i), d1.n.allv(i));
end
subplot(121)
Y = d1.n.allv;
colors = {'r','y','g','g','b','b','c','k','m'};
for i = 1:9
    Y2 = zeros(1,9);
    Y2(1,i) = Y(1,i)+.01;
    bar3(Y2,colors{i}); hold on
end
zlabel('#Events/Year')
lh = legend(labels,'Location','SouthWest');
set(lh,'Position',[0.03 0.04 0.228 0.25333])
set(gca,'YTick',[])
view(-40,15)
title(sprintf('Detector%.0f AntiNeutrino Sources (%.0fm, SBR=%.3f)\n %.3f/Yr Total, Energy Cut at %.2fMeV', d1.number, d1.detectordepth,p(1)/sum(p(2:9)),d1.n.all,input.ecut.value))

% %FIGURE TWO, SPECIFIC EVENT SOURCES
% set(figure,'Position',[10 50 1300 800]);
% np = 10;
% 
% subplot(221)
% [n i] = sort(d1.reactors.npe(1:input.reactor.IAEAdata.unique.n),1,'descend');
% i=i(1:np); n=n(1:np);
% labels=[];
% for j = 1:np
%     labels{j} = [input.reactor.IAEAdata.unique.sitename{i(j)} ', ' input.reactor.IAEAdata.unique.country{i(j)} ' (' sprintf('%.1f',input.reactor.IAEAdata.unique.GWth(i(j))) 'GWth)'];
% end
% barh(n, 'y'); axis tight
% set(gca,'YTickLabel',labels)
% title('IAEA Reactors'); xlabel('events/yr')
% 
% %SUBPLOT2
% subplot(223)
% npeid = accumarray(d1.crust.id, d1.crust.npe(:,1)+d1.crust.npe(:,2) );
% [n i] = sort(npeid, 1, 'descend');
% i=i(1:np); n=n(1:np);
% labels=[];
% for j = 1:np
%     id = i(j);
%     labels{j} = [sprintf('%s #%.0f, [%.0f, %.0f]deg', table.crust.layerNames{table.crust.all.layer(id)}, id, table.crust.all.lla(id,1), table.crust.all.lla(id,2))   ];
% end
% barh(n, 'g'); axis tight
% set(gca,'YTickLabel',labels)
% title('Crust Tiles'); xlabel('events/yr')
% 
% %SUBPLOT2
% subplot(222)
% countries = unique(input.reactor.IAEAdata.unique.country);
% npe = zeros(numel(countries),1);
% for i = 1:numel(countries)
%     for j = 1:input.reactor.IAEAdata.unique.n
%         if strcmp(countries{i},input.reactor.IAEAdata.unique.country{j})
%         npe(i) = npe(i) + d1.reactors.npe(j);
%         end
%     end
% end
% [n, i] = sort(npe,1,'descend');
% i=i(1:np); n=n(1:np);
% labels=[];
% for j = 1:np
%     labels{j} = countries{i(j)};
% end
% barh(n, 'y'); axis tight
% set(gca,'YTickLabel',labels)
% title('IAEA Countries'); xlabel('events/yr')
% 
% 
% %SUBPLOT2
% subplot(224)
% npelayer = accumarray(table.crust.all.layer, npeid );
% barh(npelayer, 'g'); axis tight
% set(gca,'YTickLabel',table.crust.layerNames)
% title('Crust Layers'); xlabel('events/yr')
% 
% figure(f1)


f1 = figure; set(f1,'Units','centimeters','Position',[.1 1.1 19 9.5]);
subplot(121)

subplot(122)

end





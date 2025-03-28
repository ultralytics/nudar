% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

geo1 = zeros(300,table.mev.ne);
kr1 = zeros(300,table.mev.ne);
for i = 1:300
    updateDetectors
    geo1(i,:) = d.z.epdf.allgeo;
    kr1(i,:) = d.z.epdf.kr;
end

v1 = 1:600;
e = stable.mev.evis(v1);


s2 = mean(geo1(:,v1),1);   gain=1/sum(s2)/(e(2)-e(1));
s2std = std(geo1(:,v1),1);  s2=s2*gain;  s2std=s2std*gain;  s{1}=s2;  sstd{1}=s2std;

s2 = mean(kr1(:,v1),1);  gain=1/sum(s2)/(e(2)-e(1));
s2std = std(kr1(:,v1),1);  s2=s2*gain;  s2std=s2std*gain;   s{2}=s2;  sstd{2}=s2std;



set(figure,'Units','centimeters','Position',[.1 1.1 19 9.5]);
ha1=subplot(121);  set(ha1,'Units','Normalized','Position',[.05 .1 .44 .8])
ha2=subplot(122);  set(ha2,'Units','Normalized','Position',[.558 .1 .44 .8])

colors = {'b','r'};

for i = 1:2
c = colors{i};

h1(i) = plot(ha1, e, s{i},c,'LineWidth',1.5); hold(ha1,'on')
h2(i) = plot(ha1, e, s{i}+sstd{i},c,'LineWidth',.5,'Color',c);
plot(ha1, e, s{i}-sstd{i},c,'LineWidth',.5,'Color',c);
axis(ha1,'tight'); xlabel(ha1,'E_{vis}','units','normalized','position',[.5 -.05]); 
ylabel(ha1,'pdf','units','normalized','position',[-.08 .5]); title(ha1,'Energy Spectra \pm Oscillation Uncertainty')
grid(ha1,'on')

fu{i} = sstd{i}./(s{i}+1E-100);
plot(ha2, e, fu{i}, c, 'LineWidth',1); hold(ha2,'on')
axis(ha2,'tight'); xlabel(ha2,'E_{vis}','units','normalized','position',[.5 -.05]); 
ylabel(ha2,'Fractional Uncertainty','units','normalized','position',[-.09 .5]); title(ha2,'Energy Spectra Fractional Uncertainty due to Oscillation Uncertainty  ')
grid(ha2,'on')
end

legend([h1(1) h1(2)], '\nu_{geo} spectrum \mu \pm 1\sigma', '\nu_{IAEA} spectrum \mu \pm 1\sigma')
legend(ha2, sprintf('\\nu_{geo} mean \\sigma_{osc} = %.3f',sum(fu{1}.*s{1})/sum(s{1})), sprintf('\\nu_{IAEA} mean \\sigma_{osc} = %.3f',sum(fu{2}.*s{2})/sum(s{2})))


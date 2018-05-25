r=1; %km

op1 = [7.58E-5, 2.35E-3, 0.312, 0.025];
f1 = fcnspec1f(r, table.mev.e, op1);

s=fcnspec1s(table.mev.eall, r, [], 0, 1, 1, table.mev.pdf0, f1);
set(figure,'Position',[10 40 900 400])
plot(table.mev.e, s.s,'b','linewidth',2); hold on

epdfallr = fcnsmearenergy(input, table, table.mev.eall, s.s, table.mev.e);
plot(table.mev.e, epdfallr,'r','linewidth',2); hold on

table2 = table;
table2.d(input.di).Estd([1 1:10], input.ci) = table.d(input.di).Estd([1 1:10], input.ci)*4/11.23; table2.mev.smeared.gpdfs=[];
epdfallr = fcnsmearenergy(input, table2, table.mev.eall, s.s, table.mev.e);

plot(table.mev.e, epdfallr,'g','linewidth',2); hold on; axis tight; xlabel('E (MeV)')
legend(sprintf('True %.1fkm Spectra (Fogli ML point)',r), ...
sprintf('Measured %.1fkm Spectra, 11.2%% SNIF Energy Resolution',r), ...
sprintf('Measured %.1fkm Spectra, 4%% Hypothetical Energy Resolution',r))





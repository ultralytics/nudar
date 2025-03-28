% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

function d1 = fcngetnonneutrinos(d1, input, table)

if isempty(d1.nonneutrinos) || d1.nonneutrinos.depth~=d1.detectordepth
    %fprintf('Non-Neutrino Vetos... ')
    %nn = compute_nnbackgrounds_for_SNIF(d1, input, table, table.d(input.di).detector.volume, -d1.detectordepth, ...
    %    .22, table.mev.fastneutron.eall, table.mev.fastneutron.pdfall, table.mev.accidental.pdfall, table.mev.cosmogenic.pdfall);
    
    nn = compute_nnbackgrounds_for_SNIF(d1, input, table, table.d(input.di).detector.volume, -d1.detectordepth, ...
        .22, table.mev.fastneutron.e, table.mev.fastneutron.pdf, table.mev.accidental.pdf, table.mev.cosmogenic.pdf);
    
    nn.depth = d1.detectordepth;
    dc.muonveto = 1 - nn.muon_DT_percent/100; %muon veto time (200microsec)
    dc.cosmogenicveto = 1 - nn.cosmo_DT_percent/100; %cosmo spallation veto time (1000millisec)
    dc.operational = 0.999; %time detector is actually on
    dc.all = dc.muonveto*dc.cosmogenicveto*dc.operational;
    d1.nonneutrinos = nn;
    d1.dutycycle = dc;
end

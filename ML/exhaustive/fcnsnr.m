% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

function d1 = fcnsnr(input, table, d1)
epdf = d1.epdf.allbackground/sum(d1.epdf.allbackground);
snr10 = table.d(input.di).rVecMag(:,input.ci)./table.d(input.di).rVecStd(:,input.ci) / input.dNoiseMultiplier;
snrv1 = interp1([0 2:11]', [snr10(1) snr10']', table.mev.e');


ct = linspace(-1,1,3600)'; st=(1-ct.^2).^(1/2); %cosine theta lookup table
d1.snr.val = epdf*snrv1;
d1.snr.vec = snrv1;
d1.snr.apdf = fcnthetapdf(d1.snr.val, ct, st); %dan's eqn;
d1.snr.ct = ct;
end


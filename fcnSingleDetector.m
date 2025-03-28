% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

function d1 = fcnSingleDetector(d1, table, input)
fprintf('Creating Detector %.0f Measurements... ',d1.number); startclock=clock;
udxecef=[]; zel=[]; zaz=[]; ze=[];
d2 = d1;

[d2.n, d2.epdf, d2.aepdf] = fcnmeanspectra(input, table, d2, 1);
n = fcnRandomPoisson(d2.n.all);

%CREATE MEASUREMENTS VIA CDF, MANUALLY APPLY ANGLE SMEAR ------------------
geov1 = table.mev.geov1;
ne = table.mev.ne;
ngeo = numel(table.mantle.udxeli);
nkr = numel(d2.n.krv);
igeo = 1:ngeo;
ikr = ngeo+(1:nkr+1);
inn = ikr(end) + (1);

aepdf = zeros(ngeo+nkr+1+1,ne);
aepdf(igeo,geov1) = d2.aepdf.crust + d2.aepdf.mantle;
aepdf(ikr,:) = d2.aepdf.allr;
aepdf(inn,:) = d2.epdf.nonneutrinos;
udx = [d1.mantle.udxecef; d1.reactors.udxecef; 1 0 0];

if n>0
    i = fcnrandcdf(cumsum(aepdf(:)),1:numel(aepdf),n,'nearest'); %get measurements
    [si,ei] = ind2sub(size(aepdf),i); %source indices and energy indices
    ze = table.mev.e(ei)';
    
    snr = d1.snr.vec(ei);
    dx = udx(si,:); %true direction
    i=si==inn; dx(i,:) = isovecs(sum(i));
    udxecef = fcnvec2uvec( bsxfun(@times,dx,snr) + randn(n,3) );
end


%SAVE RESULTS -----------------------------------------------------
[d1.z.t, i] = sort(ceil(rand(n,1)*input.detectorCollectTime)); %sort by measurement time

d1.z.e = ze(i);
d1.z.udxecef = udxecef(i,:);
d1.z.ei = fcnindex1(table.mev.e, d1.z.e);
d1.z.candidate = ones(n,1);

i = d1.z.e < table.mev.e(geov1(end));
d1.z.ge = d1.z.e(i);
d1.z.gudxecef = d1.z.udxecef(i,:);
d1.z.gei = d1.z.ei(i);
d1.z.gi = i;

d1.z.nallv = d2.n.allv;
d1.z.epdf = d2.epdf;
d1.z.n = d2.n;

fprintf(' Done... (%.2fs)\n', etime(clock,startclock))
end

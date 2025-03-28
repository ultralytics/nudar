% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

function [pdfys, gpdfs] = fcnsmearenergy(input, table, pdfx, pdfy, pdfxi)
%CONDITIONS ONE PDF ON ANOTHER!

if size(pdfx,1)==1; %make into row vector
    pdfx = pdfx';
end

if size(pdfy,2)==1; %make into row vector
    pdfy = pdfy';
end
ny = size(pdfy,1);

if nargin==4
    x = pdfx';
else
    if size(pdfxi,2)==1; %make into row vector
        pdfxi = pdfxi';
    end
    x = pdfxi;
end

if isempty(pdfx); pdfys = zeros(ny,numel(pdfxi)); gpdfs=[]; return; end; %in case K is completely out of energy range

z       = pdfx; %what we come in with, x is where we want to go
dz      = z(2)-z(1);
dx      = x(2)-x(1); %dE (MeV)
nx      = numel(x);
nz      = numel(z);

if ~isfield(table.mev.smeared,'gpdfs') || isempty(table.mev.smeared.gpdfs)
    s = qinterp1([0 2:11]', table.d(input.di).Estd([1 1:10], input.ci), z, 1);
    
    num = bsxfun(@minus, x, z).^2;
    den = repmat((2*s).^2,[1 nx]);
    gpdfs = (1./sqrt((pi/dx^2)*den)).*exp(-num./den); % gauss pdf of the measurements, CONVERT TO SINGLE FOR SPEED
    gpdfs(gpdfs<1E-8) = 0; %FASTER!
    pdfys = [];
    %fig; pcolor(table.mev.evis,table.mev.evis,gpdfs); shading flat; axis tight; xyzlabel('observed E_{vis} (MeV)','true E_{vis} (MeV)'); colorbar
    return
end

if nx*nz==table.mev.ne^2
    gpdfs = table.mev.smeared.gpdfs;
else
    zi = fcnindex1(table.mev.eall,z);
    xi = fcnindex1(table.mev.eall,x);
    gpdfs = table.mev.smeared.gpdfs(zi,xi);
end

i = find(sum(pdfy)~=0);
pdfys = pdfy(:,i)*gpdfs(i,:); %equal but faster!
%pdfys = pdfy*gpdfs;


if dx~=table.mev.de %then energy spacing is not equal to the gpdfs spacing of 0.01MeV
   pdfys = pdfys * (dx/table.mev.de);
end

% figure; 
% subplot(221)
% pcolor(x,pdfx,gpdf); shading flat
% subplot(222)
% pcolor(pdfy); shading flat
% subplot(223)
% pcolor(pdfys); shading flat
end
function [] = fcnContextPlotDetectorCrustTiles(input, table, flags, d)
st = d.crust;
ht = [];
colors = {'k','r','g','b','m','c','y','w'};
for layer = 1:8
    deleteh(ht)
    input = evalin('base','input');
    extent = input.google.maps.extent + [-2 2 -2 2];
    for gen = 1:min(max(st.gen),8)
        v1 = find(st.flux(:,1)>0 & st.layer==layer & st.gen==gen); %plot layer 1 only
        if numel(v1)>0
            da = 2/2^gen; %delta angle
            
            xcenters = st.lla(v1,1)';
            ycenters = st.lla(v1,2)';
            v2 = find(xcenters>extent(1) & xcenters<extent(2) & ycenters>extent(3) & ycenters<extent(4))';
            nv2 = numel(v2);
            
            if nv2>0
                xcenters = xcenters(v2);
                ycenters = ycenters(v2);
                
                xvertices = [xcenters-da; xcenters+da; xcenters+da; xcenters-da];
                yvertices = [ycenters+da; ycenters+da; ycenters-da; ycenters-da];
                
                xy = fcnLLA2GoogleMapsXY(input,[reshape(xvertices,numel(xvertices),1), reshape(yvertices,numel(yvertices),1), zeros(numel(xvertices),1)]);
                
                xvertices = reshape(xy(:,1),4,nv2);
                yvertices = reshape(xy(:,2),4,nv2);
                
                h = patch(xvertices, yvertices, yvertices*0,'w', ...
                    'EdgeColor',[.6 .6 .6], ...
                    'EdgeAlpha',.9, ...
                    'FaceColor',colors{gen}, ...
                    'FaceAlpha',.55, ...
                    'CDataMapping','direct', ...
                    'CDataMapping','scaled', ...
                    'AlphaDataMapping','none', ...
                    'FaceLighting','none', ...
                    'BackFaceLighting','unlit');
                ht = [ht h'];
            end
        end

    end    
    title(['Crust2.0 Layer' table.crust.layerNames{layer} ', press any key...'],'FontSize',15,'Color','b')
    drawnow
    pause
    deleteh(ht)
end
title('Crust2.0 Context Menu Finished','FontSize',15,'Color','k')

end






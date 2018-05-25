function ha=plotcrust1p0(names,latm,lngm,a,astr,units)
s = [360,180,9];
a = reshape(a,s);
ad = ones(size(a)); ad(~isfinite(a) | a==0)=0;


%border = [.6, 0, 0, .9, 0.1, 2.2]; ha=fig(4,2,1,2.12,border); %all with colorbars
border =  [0, .1, 0, .1, 0.1, 3.5]; ha=fig(4,2,1,1.9,border); %shared colorbar
%border = [spacingHoriztontal, spacingVertical, leftBorder, rightBorder, bottomBorder, topBorder];
for i=[1 2 3 6 4 7 5 8]
    sca; if i==1 || i==2; h=gca; h.Position(2)=h.Position(2)+.02; end;
    
    h=imagesc(lngm(:,1),latm(1,:),a(:,:,i)'); h.AlphaData=ad(:,:,i)'; h.AlphaDataMapping='scaled'; h=gca; h.ALim=[0 1];  h.CLim=[-2 2];
    %pcolor(lngm(:,1),latm(1,:),a(:,:,i)');
    
    if any(i==[1 2 3 6]); 
        if i>2; s=names{i}; s=s(find(s==' ')+1:end); else s=names{i}; end
        ht=text(0,73,s); ht.FontSize=50; ht.Color=[1 1 1]*.5; ht.HorizontalAlignment='center';
    end
    shading flat; axis equal tight off; %h=colorbar; h.Box='off';
   
    if i==1
        if isempty(units); s=sprintf('%s',astr); else s=sprintf('%s (%s)',astr,units); end; text(-170,105,s,'fontsize',50,'color',[1 1 1]*.5,'horizontalalignment','left','verticalalignment','baseline'); 
        h=colorbar; h.Location='south'; h.Box='off'; h.Position=[0.725  0.935  0.26  0.022]; h.FontSize=20;  
        h.Label.String=units;  h.Label.Units='normalized'; h.Label.Position=[0.85 0 0]; colormap(h,'Parula');
   
    end
    if i>2
        s=names{i}; s=s(1:find(s==' ')-1);
        ht=text(-179,0,s,'FontSize',50,'Color',[1 1 1]*.5,'HorizontalAlignment','center','verticalalignment','top','Rotation',90);
    end
end
fcntight('jointc sigma');

%fcnfontsize(12)

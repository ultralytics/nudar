if exist('L','var')
    L = L - max(L(isfinite(L)));
    p = exp(L);
    if flags.status.waterprior
        uw = 1-fcnunderwater(input, flags, input.google.maps.LLA(:,1), input.google.maps.LLA(:,2))'; %underwater
        uw = uw*ones(1,input.nrp);
        p = p.*uw;
    end
    p = reshape(p,input.nxy,input.nxy,input.nrp);
end
p(isnan(p)) = 0;
i = p==inf;   if any(i(:));  p(i) = max3(p(~i));  end
i = p==-inf;  if any(i(:));  p(i) = min3(p(~i));  end
rpVec = input.rpVec;

n = 200;
if flags.upsample && input.nxy<n && size(p,1)<=n
    r = linspace(0,input.nxy,input.nxy); c=r;
    z = linspace(input.rp1, input.rp2, input.nrp);
    [rm,cm,zm] = meshgrid(r,c,z);
    
    ri = linspace(0,input.nxy,n); ci=ri;
    zi = linspace(input.rp1, input.rp2, 200);
    rpVec = zi;
    [ri,ci,zi] = meshgrid(ri,ci,zi);
    p=interp3(rm, cm, zm, p, ri, ci, zi, '*linear');
    
    in2=input;  in2.nxy=n;  dx=640/n;  in2.google.maps.rescale6402nxy=(dx/2+1/2 : dx : 640-dx/2+1/2);  [~,~,handles]=fcnUpdateGoogleMap(in2,d,handles,flags,table);  clear in2
    set(handles.IAEAPoints,'Marker','o','MarkerSize',7,'MarkerEdgeColor',[.8 .8 .8],'MarkerFaceColor','y', 'XData',get(handles.IAEAPoints,'XData')*input.nxy/n, 'YData',get(handles.IAEAPoints,'YData')*input.nxy/n)
    for i=1:numel(handles.IAEAText)
        set(handles.IAEAText(i),'Position',get(handles.IAEAText(i),'Position')*input.nxy/n)
    end
end

%PRINT
fprintf(' Done (%.2fs)',etime(clock,startclock))
fprintf('\nGains:          IAEA     mantle      crust      fastn accidental cosmogenic     allgeo        all\n')
fprintf('Random:   '); fprintf('%10.3f ',input.fluxnoise.systematic.rand); fprintf('\n')
fprintf('Estimated:'); fprintf('%10.3f ',input.fluxnoise.systematic.estimated); fprintf('\n')

%INIT VARS ----------------------------------------------------------------
nxyt    = size(p,1); %number of temp xy
nxytg   = nxyt/input.nxy; %gain large/small
xyv     = linspace(0, input.nxy, nxyt);
X       = ones(nxyt,1)*xyv;
Y       = X';
drp     = rpVec(2)-rpVec(1);
nd      = input.dValid.count;

%ML POINT -----------------------------------------------------------------
[isovalue, np]    = fcndsearch(p,input.CEValue/100);
[ml.val, i]       = max3(p);  ml.row=i(1);  ml.col=i(2);  ml.layer=i(3);
lla               = fcnGoogleMapsXY2LLA(input, flags, [ml.row ml.col]/nxytg);
MC.p              = p;
MC.mlpoint        = [lla(1:2), rpVec(ml.layer), ml.col, ml.row];
MC.enclosedvol    = np*(input.google.maps.pixelspacingkm/nxytg)^2*drp;

if flags.status.EstMenuPlotMarginal;  plotstr=sprintf('Marginal PDF');
    Z = sum(p,3)*drp;
    [~, i]=max3(p);  ml.row=i(1);  ml.col=i(2);
    lla = fcnGoogleMapsXY2LLA(input, flags, [ml.row ml.col]/nxytg);
else plotstr=sprintf('%.2fGWth Conditional PDF',input.reactor.power);
    F=griddedInterpolant(rpVec,1:numel(rpVec),'nearest');
    Z = p(:,:, F(input.reactor.power) );  %Z = p(:,:,ml.layer);
end
missDistance = fcnrange(input.reactor.positionECEF, lla2ecef(lla));

%GUI PLOT -----------------------------------------------------------------
evalin('base','deleteAllSurfHandles')
h1=surf(handles.GUI.axes1,X,Y,Z*0+10,Z,'EdgeColor','none','FaceAlpha',.55);

[minz, maxz] = fcnminmax(Z);
if maxz>0 && maxz~=minz
    Zs = sort(Z(:)); Zn = numel(Z); minz = Zs(round(.01*Zn));  maxz = Zs(round(.999*Zn));

    if minz==maxz; maxz=maxz+1E-15; end
    set(handles.GUI.axes1,'CLim',[minz maxz]) %max and min color axes
    h2=[]; if ~flags.status.MCmode; h2=plotMinMax(xyv, xyv, Z, handles.GUI.axes1); end
    [h3, ~, enclosedArea] = plotContour(X, Y, Z, input, flags, handles);
    newHandles = [newHandles h1 h2 h3];
else
    enclosedArea = 0;
    newHandles = [newHandles h1];
end
enclosedArea = enclosedArea/nxytg^2;

%VERBOSE OUTPUT -----------------------------------------------------------
if flags.status.verbose
    onesMat = ones(2);
    ZLim = [input.rp1 input.rp2];
    XLim = [0 nxyt];
    xyv = linspace(0, nxyt, nxyt);
    
    %PLOT DETECTORS 
    %hf=figure;  set(hf,'Units','centimeters','Position',[.1 1.1 19 9.5]*1.5,'Color','w');  newHandles=[newHandles hf];  hv=zeros(1,nd);%valid detector handles
    %hs1=subplot(121);  popoutsubplot(handles.GUI.axes1, hs1); axis vis3d;  set(hs1,'Units','Normalized','Position',[.06 .1 .44 .8])
    %hs2=subplot(122);  set(hs2,'Units','Normalized','Position',[.558 .1 .44 .8])
    
    [~,hf]=fig(1,1,2);  newHandles=[newHandles hf];  hv=zeros(1,nd);%valid detector handles
    for i = 1:nd
        plot3(input.dValid.xy(i,1)*[1 1]*nxytg, input.dValid.xy(i,2)*[1 1]*nxytg, ZLim, '-g', 'LineWidth', 2);
    end
    
    %PLOT REACTOR
    x = input.reactor.position(1,1)*nxytg;
    y = input.reactor.position(1,2)*nxytg;
    z = input.reactor.power;
    plot3(XLim, [y y], [z z], '-r','LineWidth',1);
    plot3([x x], XLim, [z z], '-r','LineWidth',1);
    plot3([x x], [y y], ZLim, '-r','LineWidth',2);  %plot3(x, y, z, '.r','MarkerSize',10);
    h = surf(XLim,XLim,onesMat*z,'FaceColor','r','EdgeColor',[1 0 0]','CData',onesMat,'facealpha',.1);
    daspect([nxyt nxyt input.rp2-input.rp1]);  view(-105,50);  axis([XLim XLim ZLim]);  caxis(fcnminmax(p));  axis vis3d
    set(gca,'ZDir','Reverse', 'YDir','Reverse')
    title('Processing...'); xlabel('Latitude (deg)'); ylabel('Longitude (deg)'); zlabel('Reactor Power (GWth)'); box on

    %PLOT IAEA
    niaea = numel(handles.IAEAPoints);
    if niaea>0
        for i=1:niaea
            hi = handles.IAEAPoints(i);
            plot3([1; 1]*get(hi,'XData')*nxytg, [1; 1]*get(hi,'YData')*nxytg, ZLim'*ones(1,numel(get(hi,'XData'))),'-','LineWidth',2,'color',get(hi,'markerfacecolor'));
        end
    end

    %LAY DOWN MAP IF MAP HAS BEEN ENABLED
    if flags.upsample;  of=flags.status.mapGoogle;  flags.status.mapGoogle=1;  end
    if flags.status.mapGoogle;  [cdata,input]=fcnGetGoogleMap(input,flags);  hm=surf(XLim,XLim,ones(2)*input.rp2,'FaceColor','Texture','EdgeColor','none','CData',cdata,'facealpha',.9);  end
    if flags.upsample;  flags.status.mapGoogle=of;  end
    
    %SET LATS AND LNGS ----------------------------------------------------
    set(gca, 'XTick', get(handles.GUI.axes1,'XTick')*nxytg, 'XTickLabel', get(handles.GUI.axes1,'XTickLabel'));
    set(gca, 'YTick', get(handles.GUI.axes1,'YTick')*nxytg, 'YTickLabel', get(handles.GUI.axes1,'YTickLabel'));

    if ~flags.status.MCmode  %plot mlpoint
        x=xyv(ml.col);  
        y=xyv(ml.row);
        z=rpVec(ml.layer);        
        fcnplotline([x y z],'-b')
        plot3(x, y, z, '.b','MarkerSize',20);
        h = surf(XLim,XLim,onesMat*z,'FaceColor','b','EdgeColor',[0 0 1]','CData',onesMat,'facealpha',.1);
    end
    
    %PLOT ISOSURFACE
    x = xyv;
    xi = 1:1:nxyt;
    y = x;
    z = rpVec;
    v = p(xi,xi,:);
   
    if ml.val > isovalue
        [xm,ym,zm]=meshgrid(x,y,z);
        xm0=x;  ym0=y;  zm0=z;
        
        if numel(strfind(input.scenario,'South Africa'))>0
            input.reactor.position = fcnLLA2GoogleMapsXY(input,[-33.655 18.437 0]);
            d(1).position = fcnLLA2GoogleMapsXY(input,input.reactor.positionLLA); 
        end

        rxy = input.reactor.position*nxytg; %reactor xy
        dxy = d(1).position*nxytg; %detector1 xy
        if numel(strfind(input.scenario,'SomaliaNR'))>0
            rxy = d(4).position*nxytg; %reactor xy
            dxy = d(1).position*nxytg; %detector1 xy
        end
        vec = fcnvec2uvec([dxy-rxy 0]);
        sc = fcnCC2SC(vec); az0=sc(:,3);

        if numel(strfind(input.scenario,'Spain'))>0
            offnorth = acosd(vec(1));
            if offnorth<45 || offnorth>135;
                verticalflag=true;
                rxy = rxy([2 1]);
                az0 = mod(az0+90,180);
            else
                verticalflag=false;
            end
        end
        
        m = 1/tand(az0);
        b = rxy(1) + -rxy(2)*m; %y intercept
        xms = [1 size(xm,3)];
        for i = 1:nxyt;
            lower = max(m*i+b, 0);
            upper = nxyt;
            vx = linspace(lower,upper,nxyt);
            xm(i,:,:) = repmat(vx',xms);
        end
        
        if numel(strfind(input.scenario,'Spain'))>0
            if verticalflag
                ym0 = ym;
                ym = xm;
                xm = ym0;
            end
        end
        
        v2 = interp3(xm0, ym0, zm0, v, xm, ym, zm, 'linear',0); %points
        %v2 = v; xm=xm0; ym=ym0; zm=zm0;
        v2(isnan(v2)) = 0;
        i = v2==inf;   if any(i(:));  v2(i) = max3(v2(~i));  end
        i = v2==-inf;  if any(i(:));  v2(i) = min3(v2(~i));  end
        
        p1 = patch(isosurface(xm,ym,zm,v2,isovalue),'AmbientStrength',1,'FaceColor',[.5 .5 .5],'EdgeColor','none','FaceAlpha',1);
        %reducepatch(p1, .5)
        %isonormals(x,y,z,v,p1) %WTF does this actually do?
        lighting phong
        material shiny
        mrp = mean([input.rp1 input.rp2]);
        mrp = mrp + randn*mrp/3;%mean reactor power
        light('Position',[0 0 mrp-100]);  light('Position',[0 0 mrp+100]);  light('Position',[-500 0 mrp]);  light('Position',[0 -500 mrp]);  light('Position',[500 0 mrp]);  light('Position',[0 500 mrp]);  camlight
        p2 = patch(isocaps(xm,ym,zm,v2,isovalue));

        set(p2,'EdgeColor','none','FaceColor','interp','SpecularColorReflectance',0,'SpecularStrength',.3);
        
        [x,y,z] = meshgrid(x,y,rpVec);
        %PLOT MAX LIKELIHOOD CONTOUR
        if ~flags.status.MCmode
            hcont = contourslice(x,y,z,v,[],[],rpVec(ml.layer), [isovalue isovalue]);  set(hcont,'EdgeColor',[0 0 1])
        end
        
        %PLOT TRUE REACTOR CONTOUR
        hcont = contourslice(x,y,z,v,[],[],input.reactor.power, [isovalue isovalue]);  set(hcont,'EdgeColor',[1 0 0])

        c = get(p2,'Cdata'); c=sort(c(:)); nc=numel(c); c=c(round(.01*nc):round(.99*nc));
        [minz, maxz] = fcnminmax(c);  if minz==maxz; maxz=maxz+1E-15; end
        set(gca,'clim',[minz maxz]);
        %set(handles.GUI.axes1,'clim',[minz maxz]);
        %set(gca,'clim',get(handles.GUI.axes1,'clim')); %max figure
    end
    title({sprintf(['Enclosed %.1f%% Confidence Volume = %0.0f' 'km^2GWth'], input.CEValue, MC.enclosedvol), sprintf('Isosurface Likelihood = %0.3g', isovalue)})    
    sca(handles.GUI.axes1)
end
title(handles.GUI.axes1,['p(\Theta|Z),' sprintf(' %s, %.1fkm^2, %.1fkm',plotstr,enclosedArea,missDistance)],'Fontsize',12);

% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

if exist('L','var')
    maxL = max3(L);  if maxL==inf;  maxL=max3(L(L~=inf));  L(L==inf)=maxL;  end
    L=L-maxL;
    p=exp(L);
    if flags.status.waterprior
        uw = 1-fcnunderwater(input, flags, input.google.maps.LLA(:,1), input.google.maps.LLA(:,2))'; %underwater
        uw = uw*ones(1,input.nrp);
        p = p.*uw;
    end
    x = [input.nxy, input.nxy, input.nrp];
    p=reshape(p,x);
end

n = 200;
if flags.upsample && input.nxy<n && size(p,1)<n
    r = linspace(0,input.nxy,input.nxy); c=r;
    z = linspace(input.rp1, input.rp2, input.nrp);
    [rm,cm,zm] = meshgrid(r,c,z);
    
    ri = linspace(0,input.nxy,n); ci=ri;
    zi = linspace(input.rp1, input.rp2, input.nrp);
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
drp     = input.rpVec(2)-input.rpVec(1);
nd      = input.dValid.count;

%ML POINT -----------------------------------------------------------------
[isovalue, np]    = fcndsearch(p,input.CEValue/100);
[ml.val, i]       = max3(p);  ml.row=i(1);  ml.col=i(2);  ml.layer=i(3);
lla               = fcnGoogleMapsXY2LLA(input, flags, [ml.row ml.col]/nxytg);
MC.p              = p;
MC.mlpoint        = [lla(1:2), input.rpVec(ml.layer), ml.col, ml.row];
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
h1 = pcolor(handles.GUI.axes1, X, Y, Z);  set(h1,'EdgeColor','None','FaceAlpha',.55)

[minz maxz] = fcnminmax(Z);
if maxz>0 && maxz~=minz
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
    [hs1, hf] = fig;  set(hf,'Units','centimeters','Position',[.1 1.1 18.5 18.5]*1.5,'Color','w');  newHandles=[newHandles hf];  hv=zeros(1,nd);%valid detector handles
    popoutsubplot(handles.GUI.axes1, hs1); axis vis3d;  %set(hs1,'Units','Normalized','Position',[.06 .1 .44 .8])

   
    axes(handles.GUI.axes1)
end
title(handles.GUI.axes1,['p(\Theta|Z),' sprintf(' %s, %.0fkm^2, %.1fkm',plotstr,enclosedArea,missDistance)],'Fontsize',20);

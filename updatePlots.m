% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

if flags.reactorPlaced
    if flags.explosion
        set(handles.reactorText,'String', sprintf('   Explosion\n   %.1fkTon ',input.reactor.power),'Color',[0 0 0]);
    else
        set(handles.reactorText,'String', sprintf('   Reactor\n   %.1fGWth ',input.reactor.power),'Color',[0 0 0] );
    end
    input.reactor.position = fcnLLA2GoogleMapsXY(input, input.reactor.positionLLA );
    set(handles.reactorText,'Position',input.reactor.position);
    set(handles.reactorPoint,'XData',input.reactor.position(1),'YData',input.reactor.position(2));
end
if input.dCount>0
    set(handles.GUI.figure1,'Pointer','watch')
    for i=1:length(d)
        d(i).position = fcnLLA2GoogleMapsXY(input, d(i).positionLLA );
    end
    [input, d] = fcnCreateValidDetectorList(input, d);

    for i=1:length(d)
        
        rkr = fcnrange(d(i).positionECEF, input.reactor.IAEAdata.unique.ecef);  [rkr, j]=min(rkr);
        rur = d(i).range;
        if rur<rkr
            r = rur;
            name = 'UR';
        else
            r = rkr;
            name = input.reactor.IAEAdata.unique.sitename{j};
        end
        
        if input.dEnabled(i)   %detector enabled
            %set(handles.detectorText(i),'String', sprintf('  D%.0f, %.1fkm (%s)\n  n_Z=%.0f', i, r, name, numel(d(i).z.e)),'Color',[0 0 0]);
            set(handles.detectorText(i),'String', sprintf('  D%.0f, %.1fkm (%s)\n  %.2fdc @%.1fkm\n  n_Z=%.0f/%.0f (%.0f)', ...
                i, r, name, d(i).dutycycle.all, d(i).detectordepth/1000, d(i).n.ur, d(i).n.all, numel(d(i).z.e)),'Color',[0 0 0]);
            if flags.status.MCmode %in MC mode
                set(handles.detectorPoints(i),'Color',[0 .95*0 1])
            else %in regular mode
                set(handles.detectorPoints(i),'Color',[0 1 0])
            end
        else %detector disabled
            set(handles.detectorText(i),'String', sprintf('  D%.f\n  DISABLED',i),'Color',[.7 .7 .7])
            set(handles.detectorPoints(i),'Color',[.7 .7 .7])
        end
        set(handles.detectorText(i),'Position',d(i).position);
        set(handles.detectorPoints(i),'XData',d(i).position(1),'YData',d(i).position(2));
    end
    drawnow
    
    
    if flags.update.ML4;
        [handles.ML4, MC, d, input, flags] = fcnML4(input,handles,flags,d,stable);
        if ~flags.status.MCmode;  flags.update.ML4=0;  end
    elseif flags.update.ML0
        [handles.ML0, MC, d, input, flags] = fcnML0(input,handles,flags,d,stable);
        if ~flags.status.MCmode;  flags.update.ML0=0;  end
    else
        if flags.update.CRLB;
            [handles.CRLB, MC, d]= fcnCRLB1(input,handles,flags,d,table);
            if ~flags.status.MCmode;  flags.update.CRLB=0;  end
        end
        if flags.update.ML1;
            [handles.ML1, MC, d] = fcnML123(input,handles,flags,d,stable);
            if ~flags.status.MCmode;  flags.update.ML1=0;  end
        end
        if flags.update.ML2;
            [handles.ML2, MC, d] = fcnML123(input,handles,flags,d,stable);
            if ~flags.status.MCmode;  flags.update.ML2=0;  end
        end
        if flags.update.ML3;
            [handles.ML3, MC, d] = fcnML123(input,handles,flags,d,stable);
            if ~flags.status.MCmode;  flags.update.ML3=0;  end
        end
    end
end
set(handles.GUI.figure1,'Pointer','arrow')
clear i j name r rkr rur


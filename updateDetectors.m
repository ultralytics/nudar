if input.dCount>0;
    [input, table] = fcnosctables(input, table, flags);
    input = fcnupdatefluxnoise(input, table, d, flags);
    
    for m=1:length(d);
        if flags.update.crusttiles
            d(m).crustBrokenDownFlag = false;
            d(m) = fcnintegratecrust(d(m), table, 1);
        end
        
        lat = d(m).positionLLA(1);
        lng = d(m).positionLLA(2);
        
        d(m).positionLLA(3) = fcnGetAltitude(input, flags, lat, lng); %update altitude
        d(m).positionECEF = lla2ecef(d(m).positionLLA);
        
        d(m).waterdepth = min(d(m).positionLLA(3), 0);
        if flags.status.SeaMenuEGM96 || flags.status.SeaMenuEGM2008
            d(m).sealevelaltitude = egm1(lat,lng,input.EGM); %altitude at sea level
        elseif flags.status.SeaMenuWGS84
            d(m).sealevelaltitude = zeros(nv1,1);
        end
        d(m).detectordepth =  min(d(m).positionLLA(3) - d(m).sealevelaltitude, 0);
        
        if d(m).fakeflag    %FAKE DEPTH -> ADD TO 'create1Detector.m' ALSO!!!!
            d(m).waterdepth         = d(m).fake.waterdepth;
            d(m).detectordepth      = d(m).fake.detectordepth;
            d(m).sealevelaltitude   = d(m).fake.sealevelaltitude;
        end
        
        d(m) = fcngetnonneutrinos(d(m), input, stable);
        d(m).range = fcnrange(d(m).positionECEF, input.reactor.positionECEF);
        d(m).number = m;
        d(m).mass = input.detectorMass;
        d(m).nprotons = input.detectorProtons;
        
        d(m) = fcnSingleDetector(d(m), table, input);
    end
    flags.update.crusttiles = 0;
    
end

%CLEAR VARIABLES FROM WORKSPACE
clear m lat lng



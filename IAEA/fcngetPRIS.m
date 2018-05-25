function [X, status] = fcngetPRIS()
%[~,~,X] = xlsread('IAEA PRIS April 2014.xls');  X=X(1:end,:);  save('IAEA PRIS April 2014.mat','X');
clc; startclock=clock;
labels = {'Country','Sitename','Location','Status','Gross (MWe)','Thermal (MWt)','Mean Load Factor (%)','Current Load Factor (%)','lat','lng','alt (m)','IAEA url','Google Maps URL'};
fprintf('%25s',labels{1},labels{2},labels{3},labels{4},labels{5},labels{6},labels{7},labels{8},labels{9},labels{10})

n = 1200;
X = cell(n,13);  Y={'',''};  status=zeros(n,1);
j=0;
for i=1:n
    urlstr = sprintf('https://www.iaea.org/PRIS/CountryStatistics/ReactorDetails.aspx?current=%g',i);
    [s, status(i)] = urlread(urlstr,'Timeout',15);
    
    if status(i)==0; fprintf('\nNothing found for PRIS entry %g...',i); continue; end; %skip bad urls
    j=j+1;
    
    %COUNTRY CODE AND COUNTRY NAME    
    t = '<a id="MainContent_litCaption" href="/PRIS/CountryStatistics/CountryDetails.aspx?current=(.+)"><font color="DarkGray">(.+)</font></a>';    t=regexpsafe(t,'?');
    c = regexp(s,t,'tokens');  c=c{1};  X(j,1)=c(1,1);  %d=c{1,2};
    d=upper( fcnISO3166(c(1,1)) );
    switch d
        case 'KOREA, REPUBLIC OF'          
            d='SOUTH KOREA';
        case 'IRAN, ISLAMIC REPUBLIC OF'   
            d='IRAN';
        case 'TAIWAN, CHINA'         
            d='TAIWAN';
        case 'UNITED STATES OF AMERICA'   
            d='UNITED STATES';
    end
    X{j,2}=d;

    %SITE NAME
    t = 'MainContent_MainContent_lblReactorName"><b>(.+)</b>';
    c = regexp(s,t,'tokens');  X(j,3)=c{1};
    
    %LOCATION
    %[X(j,4), Y] = reactorname2locationname(X(j,1:3),Y);
        
    %STATUS
    t = 'MainContent_MainContent_lblReactorStatus">([\(\)\s\w-,.]+)<';
    c = regexp(s,t,'tokens');  X(j,5)=c{1};

    %MWe
    t = 'MainContent_MainContent_lblGrossCapacity">(\d+)<';
    c = regexp(s,t,'tokens');  X(j,6)=c{1};
    
    %MWt
    t = 'MainContent_MainContent_lblThermalCapacity">(\d+)<';
    c = regexp(s,t,'tokens');  X(j,7)=c{1};    
    
    %AVERAGE LOAD FACTOR
    %<span id="MainContent_MainContent_lblLoadFactor">64.3 %</span>
    t = 'MainContent_MainContent_lblLoadFactor">(-?\d*\.?\d*) %<';
    c = regexp(s,t,'tokens');  if isempty(c);  c={{'0'}}; end;  X(j,8)=c{1};
    
    %CURRENT LOAD FACTOR
    c = regexpi(s,sprintf('%g',year(now)-1));  if isempty(c); c = regexpi(s,sprintf('%g',year(now)-2)); end
    if isempty(c)
        X{j,9}='0';
    else
        u = s((1:1500)+c(end));  u=u(~isspace(u));
        t = '<tdalign="right">(-?\d*\.?\d*)</td>';
        c = regexp(u,t,'tokens');  
        if numel(c)==8 && ~isempty(cell2mat(c{7})); X(j,9)=c{7}; else X{j,9}='0'; end
    end
    
    %LLA
    %googleaddress = sprintf('%s nuclear power plant near %s %s',X{j,3},X{j,4},X{j,2});
    googleaddress = sprintf('%s nuclear power plant in %s',X{j,3},X{j,2});
    %     region = X{j,1};
    %     lla = fcnGoogleGeocodingAPI(googleaddress,region); %address to LLA
    %     X{j,10} = lla(1);
    %     X{j,11} = lla(2);
    %     X{j,12} = lla(3);
    
    lla = wikipediareactorsearch(googleaddress);  if all(lla==0); lla = wikipediareactorsearch(sprintf('%s nuclear power plant',X{j,3})); end
    X(j,4) = googlegeocodingAPI(lla);
    
    
    switch X{j,3}
        case 'MZFR'
            lla = [49.10431 8.432586 0];
        case 'NIEDERAICHBACH'
            lla = [48.605802 12.300085 0];
        case 'HDR GROSSWELZHEIM'
            lla = [50.055145 8.984869 0];
    end
    X{j,10} = lla(1);
    X{j,11} = lla(2);
    X{j,12} = lla(3);
    
    %URL
    X{j,13} = urlstr;
    
    fprintf('\n%25s%25s%25s%25s%25s%25s%25s%25s%25g%25g',X{j,2},X{j,3},X{j,4},X{j,5},X{j,6},X{j,7},X{j,8},X{j,9},X{j,10},X{j,11})
    for k=6:9
        X{j,k} = str2double(X{j,k});
    end
end
X=sortrows(X(1:j,:),[1 3]); %sort by country code and then sitename
fprintf('\n\n')

llag = cell2mat(X(:,10:12));  llag(:,3) = fcnGoogleElevation(llag(:,1),llag(:,2)); %meters above geoid
lla = llag2lla(llag);  X(:,12) = num2cell(lla(:,3),2);%meters above WGS84 ellipsoid

Y=X; %Y is for spreadsheet
for i=1:size(X,1)
    Y{i,13} = sprintf('=HYPERLINK("%s", "PRIS")',X{i,13});
    
    urlstr = sprintf('http://maps.google.com?q=%.6f,%.6f&t=k',X{i,10},X{i,11}); %http://moz.com/ugc/everything-you-never-wanted-to-know-about-google-maps-parameters
    Y{i,14} = sprintf('=HYPERLINK("%s", "Map")',urlstr);
    
    googleaddress = sprintf('%s nuclear power plant in %s',X{i,3},X{i,2});   
    urlstr = sprintf('%s%s','https://www.google.com/search?q=',googleaddress); urlstr=strrep(urlstr,' ','+'); %Google Search
    Y{i,3} = sprintf('=HYPERLINK("%s", "%s")',urlstr,X{i,3});
    
    fcnGoogleStaticMapsAPI(X{i,10},X{i,11},16,sprintf('%s %s reactor in %s.jpg',X{i,3},X{i,5},X{i,2}))
    pause(2)
end

pname = cd;
fname = ['IAEA PRIS ' datestr(now,'ddmmmyyyy')];  a=[pname filesep fname '.mat'];  fprintf('Writing ''%s''...\n',a)
save(a,'X','Y','status'); 

fprintf('%g reactors successfully read out in %.1fs...\n%g Google geocoding failures found.\n',j,etime(clock,startclock),sum(lla(:,1)==0))
end

function [location] = googlegeocodingAPI(lla)
url = sprintf('https://maps.googleapis.com/maps/api/geocode/json?latlng=%.6f,%.6f&key=%s',lla(1),lla(2),GoogleAPIkey); 
wo=weboptions; wo.Timeout=60;  S=webread(url,wo);

location = 'UNKNOWN LOCATION';

try
    n=numel(S.results);
    for si=1:n
        if isstruct(S.results); sr=S.results(si); else sr=S.results{si}; end
        i=find(strcmp({sr.types},'locality'),1,'first');
        if isempty(i); i=find(strcmp(sr.types,'colloquial_area'),1,'first'); end
        if isempty(i); i=find(strcmp(sr.types,'administrative_area_level_3'),1,'first'); end
        if isempty(i); i=find(strcmp(sr.types,'administrative_area_level_2'),1,'first'); end
        if isempty(i); i=find(strcmp(sr.types,'administrative_area_level_1'),1,'first'); end

        if ~isempty(i); 
            %a=sr.address_components; na=numel(a);  location=sr.address_components(na-1).long_name;
            location=sr.formatted_address;
            location=strrep(location,'State of ','');
            location=location(1:find(location==',',1,'last')-1);
            break; 
        end
    end
catch

end
location={location};
end

function lla = wikipediareactorsearch(address)
    %Selects first wikipedia article on a google search and gets its lat/lng
    lla = zeros(1,3);
    
    %urlstr = sprintf('%s%s','https://www.google.com/search?btnI=1&q=',address); urlstr=strrep(urlstr,' ','+'); %Feeling Lucky Search
    urlstr = sprintf('%s%s','https://www.google.com/search?q=Wikipedia: ',address); urlstr=strrep(urlstr,' ','+'); %Regular Google Search
    [s, status] = urlread(urlstr,'Timeout',15);  if status==0; return; end

    c = regexpi(s,'https://en.wikipedia.org/wiki/'); if isempty(c); return; end; d=s(c(1)+(0:300)); d=d(1:find(d=='&',1,'first')-1);
    d=strrep(d,'%25C3%25B3','o'); %Asco (replace foreign accent marks)
    d=strrep(d,'%25C3%25B2','o'); %Vandellos
    d=strrep(d,'%25C3%25AD','i'); %Vandellos
    d=strrep(d,'%25C3%25B1','n'); %Vandellos
    d=strrep(d,'%25C5%258D','o'); %Tokai
    d=strrep(d,'%25C4%2583','a'); %Cernavoda
    d=strrep(d,'%25C5%25A1','s'); %Krsko
    d=strrep(d,'%25E2%2580%2593','-'); %CVTR
    d=strrep(d,'%25C5%258C','O'); %Oma
    d=strrep(d,'%25C3%25A9','e'); %Phenix
    d=strrep(d,'%25C3%25B6','o'); %Gosgen
    d=strrep(d,'%25C3%2585','A'); %Agesta
    d=strrep(d,'%25C3%25A4','a'); %Barseback
    d=strrep(d,'%25C3%25BC','u'); %Krummel

    [s, status] = urlread(d,'Timeout',15,'Charset','UTF-8');  if status==0; return; end
    
    %'<span class="geo">40.1808444; 44.1489083</span>'
    t = '<span class="geo">(-?\d*\.?\d*); (-?\d*\.?\d*)</span>';
    c = regexpi(s,t,'tokens'); if isempty(c); return; end;  c=c{1};
    lla = [eval(c{1}), eval(c{2}), 0];
end

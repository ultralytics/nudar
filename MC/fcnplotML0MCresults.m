% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

function [h] = fcnplotML0MCresults(input, table, ~, ~, ~, ~, s, ~)
%matfname=ls('*.mat');

%for ii = 1:5
    %load(matfname(ii,:));
    %s = systematic;
    %FileName=strrep(matfname(ii,:),'.mat','.fig');

    h = [];
    startclock = clock; %#ok<NASGU>
    alpha1=.6;
    
    ni = numel(input.fluxnoise.systematic.labels);
    ha=fig(2,ni,1);
    a=.7; b=1.3;
    binx = linspace(a,b,50)';
    for i = 1:ni
        sca(ha(i))
        [n, x]=fcnhist(s.true(:,i),binx); truemu = sum(x.*n)/sum(n);
        h1 = bar(x,n,1); hold on; set(h1,'EdgeColor','none','FaceColor',[.7 .7 .7]); alpha(alpha1)
        [n, x]=fcnhist(s.est(:,i)-s.true(:,i)+1,binx); estmu = sum(x.*n)/sum(n);
        h1 = bar(x,n,1);  set(h1,'EdgeColor','none','FaceColor','b');  alpha(alpha1);  set(gca,'xlim',[a b])
        title(input.fluxnoise.systematic.labels{i});  s1=std(s.est(:,i)-s.true(:,i));  legend(sprintf('%.2f%%',100*std(s.true(:,i))), sprintf('%.2f%%',100*s1)); legend boxoff
        
        sca(ha(i+ni))
        x=s.true(:,i);  y=s.est(:,i);  p=polyfitOrthogonal(x,y,1);
        plot(x,y,'.','markersize',1); axis equal square tight; hold on; grid on
        plot([a b], polyval(p,[a b]),'r','LineWidth',1);
        plot([a b],[a b],'color',[.7 .7 .7],'LineWidth',1)
        title({input.fluxnoise.systematic.labels{i},sprintf('%.3f correlation\n%.3f true mu\n%.3f est mu',corr(x,y),truemu,estmu)})
        set(gca,'xlim',[a b],'ylim',[a b]);
        if i==1 ; xlabel('True Systematic'); ylabel('Est. Systematic'); end
        
        %mcf1s(ii,i)=s1;
    end
    fcnlegend(hf,alpha1)
    drawnow
    
    ni = numel(input.osc.true.mu);
    ha=fig(2,ni,.6); 
    for i = 1:ni
        j = i+9;
        t1 = s.true(:,j);
        e1 = s.est(:,j);
        u1 = table.osc.u(i);
        vt = t1>u1;
        
        x = table.osc.x(i,:)';
        x = linspace(x(1),x(end),50)';
        xlim = fcnminmax(x);
        
        sca(ha(i))
        n=fcnhist(t1,x); truemu = sum(x.*n)/sum(n);
        h1 = bar(x,n,1); hold on; set(h1,'EdgeColor','none','FaceColor',[.7 .7 .7]); alpha(alpha1)
        n=fcnhist(e1-t1 + u1,x); estmu = sum(x.*n)/sum(n);
        h1 = bar(x,n,1);  set(h1,'EdgeColor','none','FaceColor','b');  alpha(alpha1);  set(gca,'xlim',xlim)
        title(input.osc.labels{i});
        str = '%.2g (%.2f%%)';
        t1s = fcnstd(t1(vt),u1);
        t2s = fcnstd(t1(~vt),u1);
        e1s = std(e1(vt)-t1(vt));
        e2s = std(e1(~vt)-t1(~vt));
        legend(['\mu^{+' sprintf(str,t1s,100*t1s/u1) '}_{-' sprintf(str,t2s,100*t2s/u1) '}'], ...
            ['\mu^{+' sprintf(str,e1s,100*e1s/u1) '}_{-' sprintf(str,e2s,100*e2s/u1) '}'])
        legend boxoff
        axis tight;  set(gca,'ylim',get(gca,'ylim')*1.4);
        
        sca(ha(i+ni))
        p=polyfitOrthogonal(t1,e1,1);
        plot(t1,e1,'.','markersize',1); axis equal square tight; hold on; grid on
        plot(xlim, polyval(p,xlim),'r','LineWidth',1);
        plot(xlim,xlim,'color',[.7 .7 .7],'LineWidth',1)
        title({input.osc.labels{i},sprintf('%.3f correlation\n%.3g true mu\n%.3g est mu',corr(t1,e1),truemu,estmu)})
        set(gca,'xlim',xlim,'ylim',xlim);
        if i==1 ; xlabel('True Osc Parameter'); ylabel('Est Osc Parameter'); end
        
        %mc1su(ii,i)=e1s;
        %mc1sl(ii,i)=e2s;
    end
    fcnlegend(hf,alpha1)
    drawnow
    
    
%     fh = findall(0,'Type','figure'); %figure handles
%     v1 = fh~=handles.GUI.figure1;
%     hgsave(fh(v1),FileName)
%     close(fh(v1));
%     
    
end



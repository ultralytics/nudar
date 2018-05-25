input.osc.true.mu = fcnrandosc(1, input, flags);




tic
np=500;

nr=200;
rvec = linspace(2,100,nr);
s2std=zeros(nr,table.mev.ne); s2 = s2std;
for ir=1:nr
    r=rvec(ir);
    
    op = fcnrandosc(np, input, flags);
    s3 = zeros(np,numel(table.mev.e));
    for i=1:np
        %op1 = [table.osc.u(1) op(i,2) table.osc.u(3) op(i,4)];
        %op1 = [op(i,1) table.osc.u(2) op(i,3) table.osc.u(4)];
        op1=op(i,:);
        
        s = fcnspec1s(table.mev.e, r, op1, 1, 1, 1, table.mev.pdf0); %true spectrum
        s.s = (ones(1,size(s.s,2))./sum(s.s,2)).*s.s;
        
        s3(i,:)=s.s;
    end
    s2(ir,:) = mean(s3,1);
    s2std(ir,:) = std(s3,1);
end
toc

figure; pcolor(rvec,table.mev.e,s2std'); shading flat; xlabel('range'); ylabel('MeV')

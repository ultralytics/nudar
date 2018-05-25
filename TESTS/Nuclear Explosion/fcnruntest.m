% function [] = fcnruntest()
ni = 100;
input.reactor.power = 5000;

r = linspace(1,250,100);
p = [10 100 1000]; %nuclear explosion yield (kton tnt)
n = zeros(size(r),3);

for i=1:ni
    d1.range = r(i);
    for j=1:3
        input.reactor.power = p(j);
        n(i,j) = fcnexplosion(input, table, d1);
    end
end

figure; plot(r,n(:,1),'r',r,n(:,2),'g',r,n(:,3),'b');
axis tight
set(gca,'ylim',[0 100])
legend('10kT yield','100kT yield','1000kT yield')
xlabel('range (km)'); ylabel(sprintf('Observed Antineutrinos\n(85%% duty cycle, 80%% candidate efficiency)')); title('Nuclear Explosion Antineutrinos Observed in a 160kT LS detector')
fcnlinewidth(2); grid on
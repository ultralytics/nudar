function [] = fcnsavefile(filename, d, input, handles, flags)
input.ETOPO = [];
input.EGM = [];
input.reactor.IAEAdata = [];

for i = 1:input.dCount
    d(i).z = [];
    d(i).ztruth = [];
    d(i).zsigma = [];
    d(i).crust = [];
    d(i).snr = [];
    d(i).epdf = [];
    d(i).aepdf = [];
    d(i).crust = [];
    d(i).mantle = [];
    d(i).kr = [];
end
d = fcncleardtables(d, input);
handles.GUI=[];

save('-v6',filename,'d','input','handles','flags');
end


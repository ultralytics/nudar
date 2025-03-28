% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

function [a, u] = fcnloadPRIS(fname)
%a = all reactors
%u = unique sites
if nargin==0
    fname = 'IAEA PRIS 07Oct2016.mat';
    %fname = 'IAEA RRDB 07Oct2016.mat';
end
load(fname)
%X = sortrows(X,3); %#ok<NODEF> %sort by country

loadfactor = cell2mat(X(:,9)); %#ok<*NODEF> %8-historical mean, 9-latest year
capacity = cell2mat(X(:,7)); %7-capacity (GWth)
i = strcmpi(X(:,5),'Operational');
j = strcmpi(X(:,5),'Under Construction');  
%k = i | j;
k = i;
X(j,8) = {mean(loadfactor(i))}; %apply mean historical load factor to under construction reactors
X = X(k,:);

a.GWth = loadfactor(k).*capacity(k)/100/1000; %all
a.country = X(:,2);            a.sitename = X(:,3);          a.status = X(:,5);
a.lla = cell2mat(X(:,10:12));  a.ecef = lla2ecef(a.lla);     a.n = numel(a.GWth);

sites = regexprep(X(:,3),'-(\d{1,5})','','preservecase');
%[usites, I, J] = fcnunique(sites);

n=numel(sites);
C=cell(n,1);
for i=1:n
   C{i}=[sites{i} a.country{i}];
end
[~, I, J] = fcnunique(C);  usites=sites(I);

u.GWth = accumarray(J,a.GWth); %unique sites
u.country = X(I,2);           u.sitename = usites;          u.status = X(I,5);
u.lla = cell2mat(X(I,10:12));  u.ecef = lla2ecef(u.lla);     u.n = numel(u.GWth);
u.ncores = accumarray(J,1);
end

function [sites, I, J] = fcnunique(sites)
    [sites, I, J] = unique(sites);
end
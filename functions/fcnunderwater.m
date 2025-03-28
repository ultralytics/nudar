% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

function [flag] = fcnunderwater(input, flags, lat, lng)
%flag=false, not underwater
%flag=true, underwater

z1 = etopo1(lat,lng,input.ETOPO);

v1 = z1<100; %max egm alt is about 90m
nv1 = sum(v1);
flag(~v1) = 0;

if nv1>0
    z2 = 0;
    flag(v1) = z2>z1(v1);
end

end


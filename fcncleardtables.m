% Ultralytics 🚀 AGPL-3.0 License - https://ultralytics.com/license

function d = fcncleardtables(d, input)

for i = 1:input.dCount
    d(i).epdf = [];
    d(i).est = [];
    d(i).energycut = [];
end

end


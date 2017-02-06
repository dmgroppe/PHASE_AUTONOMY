function [] = zapRunAll()

%atype = {'sub_rmp', 'sub_80', 'supra_rmp'};
atype = {'supra_rmp'};

parfor i=1:numel(atype)
    %zapL23(atype{i});
    zapL5(atype{i});
end

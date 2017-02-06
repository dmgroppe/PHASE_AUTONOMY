function [uconds] = unique_condition(dap)
conds = {};
% Get all the unique conditions

for i=1:numel(dap)
    conds = [conds dap(i).cond.names];
end

uconds = unique(conds);
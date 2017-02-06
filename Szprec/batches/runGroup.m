function [] = runGroup(pt_names, sz_list, aCfg)

% Run PH analysis on a group of patients

if nargin < 3; aCfg = cfg_default(); end;

for i=1:numel(pt_names)
    runSubject(pt_names{i}, sz_list, aCfg);
end
    
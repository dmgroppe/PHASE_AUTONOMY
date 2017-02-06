function [eh_b eh_m] = electrode_remap_get(sz_name)

% Get the electrode mapping since there are cases that electrode locations
% can physiclaly change.

pt_name = strtok(sz_name, '_');

e_hack_func = sprintf('%s_electrode_hack', pt_name);

if exist(e_hack_func, 'file')
    [eh_b eh_m] = feval(str2func(e_hack_func), sz_name);
else
    eh_b = [];
    eh_m = [];
end
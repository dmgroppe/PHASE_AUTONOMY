function [] = emd_group(dap, dop)

if nargin < 2; dop = 0; end;

parfor i=1:numel(dap)
    inc = get_sf_val(dap(i), 'GroupInc');
    if strcmp(inc, 'yes') || isempty(inc)
        emd_slice(dap(i), 1, 0);
    end
end
function [] = mi_group(dap, dop)

for i=1:numel(dap)
    inc = get_sf_val(dap(i), 'GroupInc');
    if strcmp(inc, 'yes') || isempty(inc)
        mi_slice(dap(i), 1, 1, dop);
    end
end
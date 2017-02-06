function [] = pre_process(Dir, fname)

[ss, dap] = excel_read(Dir,fname);
ap = sl_sync_params();

if ss.error
    display('Something went wrong reading the excel file.')
    return;
end

nlines = numel(dap);

% Processes only those files to be included in the group analyses, only if
% the ap.prep_all flag is not set
parfor i=1:nlines
    inc = get_sf_val(dap(i), 'GroupInc');
    if strcmp(inc, 'yes') && ~ap.prep_all
        process(dap(i));
    else
        process(dap(i));
    end
end




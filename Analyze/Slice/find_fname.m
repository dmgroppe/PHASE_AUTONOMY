function [ind] = find_fname(dap, fname)

ind = [];
count = 0;
for i=1:numel(dap)
    ufile_names = unique(dap(i).cond.fname);
    for j=1:numel(ufile_names)
        if strcmpi(ufile_names(j), fname)
            count = count + 1;
            ind(count) = i;
        end
    end
end
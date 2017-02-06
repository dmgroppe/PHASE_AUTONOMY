function [ap] = set_sf_val(ap, fn, val)

% Sets the value of a special field named 'fn'

nsf = numel(ap.sf.names);

if ~nsf
    return;
end

for i=nsf
    if strcmpi(ap.sf.names{i},fn)
        ap.sf.vals{i} = val;
        return
    end
end
function [val] = get_sf_val(ap, fn)

% Return the value of a special field named 'fn'

val = [];
nsf = numel(ap.sf.names);
nsv = numel(ap.sf.vals);

if ~nsf || ~nsv
    val = [];
    return;
end

for i=1:nsf
    if strcmpi(ap.sf.names{i},fn)
        val = ap.sf.vals{i};
        return
    end
end
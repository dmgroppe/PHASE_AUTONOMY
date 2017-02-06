function [names] = subdir_print(topdir)

g = genpath(topdir);
f = textscan(g, '%s', 'delimiter', pathsep);
for i=1:numel(f{1})
    fp = textscan(f{1}{i}, '%s', 'delimiter', '\\');
    names{i} = sprintf('%s', fp{1}{numel(fp{1})});
    display(fp{1}{numel(fp{1})});
    %nparts = textscan(fp
end
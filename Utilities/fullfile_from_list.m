function [fp] = fullfile_from_list(p, subdirs)

% Make a path out of cell array of subdirectories

fp = p;
for i=1:numel(subdirs)
    fp = fullfile(fp,subdirs{i});
end
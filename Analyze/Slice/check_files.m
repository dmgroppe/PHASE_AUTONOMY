function [fpath, okay] = check_files(ap, ext)

% Tries to find the files in the Dir or subdirs in Dir.  If it can not
% able locate it then returns error

okay = 1;
ncond = numel(ap.cond.names);

for i=1:ncond
    fpath{i} = findfile(ap.Dir, [ap.cond.fname{i} ext]);
    if isempty(fpath{i})
        display('Unable to locate a specified file:');
        display([ap.Dir ap.cond.fname{i} '.abf']);
        okay = 0;
    end
end
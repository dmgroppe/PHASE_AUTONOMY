function [fpath] = findfile(path, fname)

%  Finds a file by recursively searching all the subdirectories for file
%  named 'fname'.  This is pretty slow and the 'path' variable should be
%  not so shallow in the directory tree.  Best if all the files are dumped
%  into the same directory.
%
% USAGE: [fpath] = findfile(path, fname)
% INPUT:
%   path - starting path for search
%   fname - filename with extension to find
%
% OUTPUT:
%   fpath - if the file is found the directory it is in is returned
%   otherwise empty
%
% Taufik A Valiante 2012


d = dir(path);

nitems = length(d);
fpath = [];

for i=1:nitems
    if ~d(i).isdir
        if strcmpi(d(i).name, fname);
            fpath = path;
            return;
        end
    end
end

for i=1:nitems
    if d(i).isdir
        if ~strcmp(d(i).name, '.') && ~strcmp(d(i).name, '..')
            newpath = [path,d(i).name,'\'];
            fpath = findfile(newpath, fname);
            if ~isempty(fpath)
                return;
            end
        end
    end
end


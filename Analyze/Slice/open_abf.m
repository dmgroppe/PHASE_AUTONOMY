function [fpath] = open_abf(ap, fname)
fpath = findfile(ap.Dir, [char(fname) '.abf']);

if ~isempty(fpath)
    winopen([fpath char(fname) '.abf']);
else
    display('Unable to find the specified slice')
end
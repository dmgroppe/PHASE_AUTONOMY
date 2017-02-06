function [directory] = file_get_path(ap)

if isempty(ap.Dir) || isempty(ap.fname)
    error('Directory and or filename is missing');
end

directory = findfile(ap.Dir, [ap.fname '.abf']);

if isempty(directory)
    error('Can not find specified file');
end

full_path = [directory ap.fname '.abf'];

if ~exist(full_path, 'file')
    error('Unable to open file');
end
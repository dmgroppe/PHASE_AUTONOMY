function [fpath, okay] = check_file(ap, fname, ext)

fpath = findfile(ap.Dir, [fname '.abf']);

if isempty(fpath)
    display('Unable to locate file:');
    display(sprintf('Start Dir: %s', ap.Dir));
    display(sprintf('Filename : %s', fname));
    display(sprintf('Exiting %s.', mfilename()));
    return;
end
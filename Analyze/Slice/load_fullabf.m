function [S] = load_fullabf(dDir,fn)

% Load the full ABF file

tstart = 0;
tend = 'e';

S = [];
full_path= [dDir, fn, '.abf'];

if ~exist(full_path, 'file')
    display('File does not exits');
    return;
end

[d,si,h]=abfload(full_path,'start',tstart,'stop', tend);
S = h;
S.srate = fix(1/(si*1e-6));
S.data = d';
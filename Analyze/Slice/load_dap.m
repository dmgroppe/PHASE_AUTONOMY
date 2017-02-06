function [S] = load_dap(dap, ap, fname)

fpath = findfile(dap.Dir, [fname '.abf']);

if isempty(fpath)
    display('Unable to locate file:');
    display(sprintf('Start Dir: %s', dap.Dir));
    display(sprintf('Filename : %s', fname));
    display(sprintf('Exiting %s.', mfilename()));
    error('Exiting analysis.');
end

% Load the entire file and all channels
display('Loading data...');
[S from_mat] = abf_load(fpath, fname, ap.srate, 0, 'e', ap.load_mat, ap);
S.from_mat = from_mat;

% If not from matlab file then notch filter it
if from_mat
    display('Data loaded from .mat file.');
end

% If the pre-processed file did not exist save it.  Do it here in case something
% blows up afterwards
if ~from_mat
    display('Saving to matlab file in:');
    display(prep_dir_get(fpath));
    save(fullfile(prep_dir_get(fpath), [fname '.mat']), 'S');
end
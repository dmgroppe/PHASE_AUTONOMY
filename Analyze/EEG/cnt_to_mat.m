function [cnt] = cnt_to_mat(dir, fname)

% Load a CNT and save it as a MATLAB file

fpath = [dir fname '.cnt'];

if ~exist(fpath, 'file');
    display(fpath);
    display('This file does not exist');
    return;
end

cnt = loadcnt(fpath, 'dataformat', 'int32');

opath = [dir fname '.mat'];
save(opath, 'cnt', '-v7.3');
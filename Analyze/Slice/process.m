function [] = process(dap)

% Processes files in DAP

% Get all the unique filenames for the slice
ufnames = unique(dap.cond.fname);

% Get user specified paramters
ap = sl_sync_params();

for i=1:numel(ufnames)
    fpath = findfile(dap.Dir, [ufnames{i} '.abf']);

    if isempty(fpath)
        display('Unable to locate file:');
        display(sprintf(' Start Dir: %s', dap.Dir));
        display(sprintf(' Filename : %s', ufnames{i}));
    else
        % load the whole file - make sure matfile is not loaded.  Notch
        % filtering is performed at the time of reading in the file, so not
        % done here.
        
        [S ~] = abf_load(fpath, ufnames{i}, ap.srate, 0, 'e', 0);
        
%         [nchan, npoints] = size(S.data);
%         xfilt = zeros(nchan, npoints);
%         
%         % Notch filter the data
%         if dap.notch
%             for j=1:nchan
%                 xfilt(j,:) = harm(S.data(j,:),ap.notches, ap.srate, ap.bstop, ap.nharm);
%             end
%             S.data = xfilt;
%         end
        save([prep_dir_get(fpath) ufnames{i} '.mat'], 'S');
    end
end
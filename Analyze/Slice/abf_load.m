function [S, from_mat] = abf_load(dDir,fn, new_srate, tstart, tend, load_mat, ap)

% Function to load data from an ABF file.  Decimates after filterting to
% new_srate

% If there is pre-processed matlab file then it will read that in.

if nargin < 7
    % User can specify various parameters for loading through ap passed to
    % the function, otherwise the defaults are loaded
    ap = sl_sync_params();
end

% By default load the MAT file, user must override
if nargin < 6; load_mat = 1; end;

S = [];
full_path= fullfile(dDir, [fn, '.abf']);
from_mat = 0;

% Only load if user wants to, otherwise the data will be read in from the
% ABF file
if load_mat
    opendir = char(prep_dir_get(dDir));
    full_file = fullfile(opendir, [fn, '.mat']);
    if exist(full_file, 'file')
        load(full_file);
        from_mat = 1;
        if new_srate && (new_srate ~= S.srate)
            display('WARNING: specified sampling rate is not same as loaded .MAT file');
            sprintf('srate = %6.4Hz, new_srate = 6.4f', S.srate, new_srate);
            display('If required the .MAT file should be deleted and the ABF file pre-processed to desired sampling rate.');
        end

        if strcmp(tend,'e')
            dend = length(S.data);
        else
            dend = fix(tend*S.srate);
            if dend > length(S.data) || dend <= 0
                error('Error in segment end time.');
            end
        end

        if tstart == 0;
            dstart = 1;
        else
            dstart = fix(tstart*S.srate);
            if dstart <= 0 || dstart >= length(S.data)
                error('Error in segment start time.');
            end
        end

        S.data = S.data(:,dstart:dend);
        return;
    end
end

if ~exist(full_path, 'file')
    display('File does not exits');
    return;
end

[d,si,h]=abfload(full_path,'start',tstart,'stop', tend);
S = h;
S.srate = fix(1/(si*1e-6));
d = d';
S.data = d;

[nchan, ~] = size(S.data);

% Set the frequency in ap to the data SR
fap = ap;
fap.srate = S.srate;

if new_srate && (new_srate < S.srate)
    parfor i=1:nchan
        d(i,:) = filter_resample(d(i,:), S.srate, new_srate, .0001, new_srate/ap.over_sample);
    end
    S.srate = new_srate;
end

if ap.notch
    for i=1:nchan
        if ap.notch_ch_list(i)
            d(i,:) = harm(d(i,:),ap.notches,S.srate, ap.bstop, ap.nharm);
        end
    end
end

S.data = d;
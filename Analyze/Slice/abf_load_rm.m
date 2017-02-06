function [S, from_mat] = abf_load_rm(ap,dDir,fn, new_srate, tstart, tend, load_mat,donotch)

% Function to load data from an ABF file.  Decimates after filterting to
% new_srate

% If there is pre-processed matlab file then it will read that in.

if nargin < 6; load_mat = 1; end;

S = [];
full_path= [dDir, fn, '.abf']; %path for .abf file
%Set folders/paths for files in the case of notching and/or downsampling:
notch_path = [dDir, 'notch\', fn, '_firnotch', '.mat'];
notch_folder = [dDir, 'notch\'];
downsamp_path = [dDir, 'downsamp\', fn, '_firnotch', '.mat']; 
downsamp_folder = [dDir, 'downsamp\'];
from_mat = 0;

% Only load if user wants to, otherwise the data will be read in from the
% ABF file

if exist(notch_path,'file') && load_mat == 1 && donotch == 1
    S = load(notch_path); S = S.S;
    from_mat = 1;
    if new_srate ~= S.srate
                display('WARNING: specified sampling rate is not same as loaded .MAT file');
                display('If required the .MAT file should be deleted and the ABF file pre-processed to desired sampling rate.');
    end
elseif exist(downsamp_path,'file') && load_mat == 1
    S = load(downsamp_path); S = S.S;
    from_mat = 1;
    if new_srate ~= S.srate
                display('WARNING: specified sampling rate is not same as loaded .MAT file');
                display('If required the .MAT file should be deleted and the ABF file pre-processed to desired sampling rate.');
    end
elseif ~exist(full_path, 'file')
    display('File does not exist');
    return;
else
    [d,si,h]=abfload(full_path);
    from_mat = 0;
    S = h;
    S.srate = 1/(si*1e-6);
    S.data = d';
    [nchan, ~] = size(S.data);
    clc
    for i=1:nchan
        if new_srate < S.srate %downsample if it makes sense
            y(i,:) = filter_resample(S.data(i,:), S.srate, new_srate, .0001, new_srate/4);
            %y(i,:) = y(i,:) - mean(y(i,:));
        else
            y(i,:) = S.data(i,:);
        end           
        if donotch == 1 % Notch filter it
            y(i,:) = firnotch(y(i,:),ap);
        end
    end
end

%Set data field of output
if from_mat == 0
    S.data = y;
    if new_srate < S.srate
        S.srate = new_srate;
    end
end

if donotch == 1 && from_mat == 0
    if ~exist(notch_folder, 'dir')
        mkdir(notch_folder);
    end
    save(notch_path,'S') %Save downsampled/notched data as matlab file
elseif donotch == 0 && from_mat == 0
    if ~exist(downsamp_folder, 'dir')
        mkdir(downsamp_folder);
    end
    save(downsamp_path,'S') %Save downsampled data as matlab file
end
    

%Truncate output to specified length for use in further application

if strcmp(tend, 'e') == 1
    dend = length(S.data);
else
    dend = tend*S.srate;
end

if tstart == 0
    dstart = 1;
else
    dstart = tstart*S.srate; 
end

S.data = S.data(:,dstart:dend);

end

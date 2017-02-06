function [] = autocoh_batch_stats(ptname, cond, channels, freqs, drive)

if nargin < 5; drive = 'D:'; end;

if strcmpi(ptname, 'vant')
    EEG = load_vant();
    folder = '\Projects\Data\Vant\Figures\Super\AutoCoh\Vant-CGT\';
else
    EEG = load_nourse();
    folder = '\Projects\Data\Vant\Figures\Super\AutoCoh\Nourse-CGT\';
end

% Create the directory if it does not exist
if ~exist(fullfile(drive,folder), 'dir');
    mkdir(fullfile(drive,folder));
end

% Run all the surrogates
for i=1:length(channels)
    display('Performing burst analysis...')
    [EEGCGT R] = sync_autocoh(EEG, channels(i), cond, ptname, freqs);
    
    display('Computing BURST surrogates ...');
    [R_burst_surr, ~] = sync_autocoh_surr(EEGCGT, R, 'burst', false);
    
    display('Computing NOISE surrogates ...');
    [R_noise_surr, ~] = sync_autocoh_surr(EEGCGT, R, 'noise', false);
    fname = sprintf('EEGCGT_%s_%s_CH%d.mat', upper(ptname), cond, channels(i)); 
    sfile = fullfile(drive, folder, fname);
    
    display('Saving surrogate analyses...');
    save(sfile, 'EEGCGT', 'R', 'R_burst_surr', 'R_noise_surr');
end




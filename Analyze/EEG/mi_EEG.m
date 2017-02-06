function [R channels] = mi_EEG(EEG, fname, range, window, ch_to_excl)

w_number = 5;
[lf hf ] = mi_freqs(w_number, EEG.srate);

eDir = 'D:\Projects\Data\Analyzed\EEGMI\';

[nchan, ~] = size(EEG.data);

channels = setxor(1:nchan, ch_to_excl);
data = EEG.data(channels,range(1):range(2));
srate = EEG.srate;

cfg = [];
cfg.window = window;

parfor i=1:length(channels)
    if ~window 
        R{i} = mi_grid(data(i,:), srate, lf, hf, false, [0 1e-2], false, 12, 0, 0.05);
    else
        [R{i} cfg_out{i}] = mi_grid_subr(data(i,:), srate, lf, hf, cfg);
    end
end

% save the results
save([eDir fname '.mat'], 'R', 'channels', 'window', 'cfg_out');
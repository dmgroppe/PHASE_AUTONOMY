function [] = tfa_batch(EEG, trange, frange, bline, ev_type)

[nchan] = size(EEG.data,1);

for i=1:nchan
    [h(i) fname{i}] = EEG_tfa(EEG, i, trange, frange, bline, ev_type);
end

for i=1:nchan
    save_figure(h(i), 'D:\Projects\Data\EEG Analysis\', fname{i}, false);
end

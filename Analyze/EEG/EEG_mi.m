function [] = EEG_mi(EEG, channel, trange, lfrange, hfrange, bline, ev_type)

[~, ev_loc] = events_get(EEG,ev_type);
ev_loc = fix(ev_loc/5);

ts = sim_tr_nesting(length(EEG.data), ev_loc);
%ts = EEG.data(channel,:);

h = figure(channel);
clf('reset');
mi_tr(ts, EEG.srate, trange, lfrange, hfrange, ev_loc, bline);

fname = sprintf('Time resolved CFC - Channel %d', channel);
set(h, 'Name', fname);
save_figure(h, 'D:\Projects\Data\EEG Analysis\', fname, false);
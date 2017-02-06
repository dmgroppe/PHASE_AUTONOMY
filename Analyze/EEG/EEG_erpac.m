function [] = EEG_erpac(EEG, channel, lfrange, hfrange, ev_type, perm)

[~, ev_loc] = events_get(EEG,ev_type);
ev_loc = fix(ev_loc/5);

mi_tr(EEG.data(channel,:), EEG.srate, [-1000 1000], lfrange, hfrange, ev_loc, 500, perm);
function [h fname] = EEG_tfa(EEG, channel, trange, frange, bline, ev_type)

[~, ev_loc] = events_get(EEG,ev_type);
%ev_loc = fix(ev_loc/5);
h = figure(channel);
clf('reset');
tfa_tr(EEG.data(channel,:), EEG.srate, trange, frange, ev_loc, bline);
fname = sprintf('TFA Channel %d', channel);
set(h, 'Name', fname);
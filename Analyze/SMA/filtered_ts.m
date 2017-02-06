function [x, xfilt] = filtered_ts(EEG, ch, cond, length, frange, ptname)

[tstart tend] = get_trange(cond, length, ptname);
x = get_subregion(EEG, tstart, tend);
x = x(ch,:);

d = window_FIR(frange(1), frange(2), EEG.srate);
xfilt = filtfilt(d.Numerator, 1, x);
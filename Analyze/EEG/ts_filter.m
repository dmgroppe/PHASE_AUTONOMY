function [xfilt] = ts_filter(x, f1, f2, srate)
filt = window_FIR(f1, f2, srate);
xfilt = filtfilt(filt.Numerator, 1, x);
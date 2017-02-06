function [xdec, new_rate] = sl_filter_resample(data, filtrange, old_rate, new_rate)

d = window_FIR(filtrange(1), filtrange(2), old_rate);
xfilt = filtfilt(d.Numerator, 1, data);

skip = fix(old_rate/new_rate);

xdec = xfilt(1:skip:end);
new_rate = old_rate*length(xdec)/length(data);

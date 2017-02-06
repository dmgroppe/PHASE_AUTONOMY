function [filt] = tfilter(x, Hd)
filt = filtfilt(Hd.Numerator,1,x);
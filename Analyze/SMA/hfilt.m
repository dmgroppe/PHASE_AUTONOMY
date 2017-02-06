function [xf, hx] = hfilt(x,f, srate)
d = window_FIR(f(1), f(2), srate);
xf = filtfilt(d.Numerator,1, x);
hx = hilbert(xf);
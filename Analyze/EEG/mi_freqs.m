function [lf hf] = mi_freqs(wnumber, srate)

wvname = sprintf('cmor%d-1',wnumber);
% 2.4-20Hz
lf = scal2frq(log_scale(8, 11, 4), wvname, 1/srate);
% 40-312Hz
hf =  scal2frq(log_scale(4, 7, 4), wvname, 1/srate);
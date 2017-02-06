function [wt, freq] = twt(data, sr, a, bw)

% function [wt, freq] = twt(data, sr, a, bw)
% Computes wavelet spectrum of data using complex morlet wavelet
% data - vector of data
% sr - sampling rate in Hz
% a - scales
% bw - band width parameter of the morlet wavelet

wvname = sprintf('cmor%d-1',bw);
wt = cwt(data, a, wvname);
freq = scal2frq(a, wvname, 1/sr);

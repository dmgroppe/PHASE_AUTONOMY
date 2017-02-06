%  USAGE [wave] = zap(amp, freq, npoints, sr)
%
%   Input:
%       amp:        Amplitude in pA
%       freq:       frequency of the sine wave [start end] 
%       nsec:       Length in s of the zap
%       sr:         Sampling
%   Output:
%       wave:       Synthetic wave
%-------------------------------------------------------------------------


function [wave, T, freqs] = zap(amp, freq, nsec, sr)

npoints = nsec*sr;
T = 0:1/sr:(nsec-1/sr);

delta = pi/(npoints-1);
freqs = freq(1):(freq(2)-freq(1))/(npoints-1):freq(2);
x = (0:(npoints-1))*delta.*freqs;
wave = amp*sin(nsec*x);
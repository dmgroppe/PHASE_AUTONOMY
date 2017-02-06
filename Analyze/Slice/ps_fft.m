function [ps, w] = ps_fft(x, srate)

L = length(x);

NFFT = 2^nextpow2(L); % Next power of 2 from length of y
ps = 2*abs(fft(x,NFFT)/L);
w = srate/2*linspace(0,1,NFFT/2+1);
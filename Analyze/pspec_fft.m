function [pwr w] = pspec_fft(x, srate)
N = length(x);
NFFT = 2^nextpow2(N);
p = 2*abs(fft(x, NFFT))/N;
w = srate/2*linspace(0,1,NFFT/2+1);
pwr = p(1:length(w));
% USAGE: [scrambled] = scramble_phase(x)
%
%   Scrambles the phase of x, preserving the power spectrum

function [scrambled] = scramble_phase(x)

x = x-mean(x);
n = length(x);
oldn = n;

n2 = nextpow2(n);
n = 2^n2;
x(oldn+1:n) = 0;

y = fft(x);

magy = abs(y(2:n/2));
randphase = rand(1,n/2-1)*2*pi;
y(2:n/2) = magy.*exp(1i*randphase);
y((n/2+2):n) = conj(y(n/2:-1:2));
scrambled = ifft(y);
scrambled = scrambled(1:oldn);
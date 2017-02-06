function [oof] = one_over_f(n)

x = rand(1,n);
y = fft(x);
y(1:(n/2+1)) = y(1:(n/2+1)).*(1./(1:(n/2+1)));
y((n/2+2):n) = conj(y((n/2):-1:2));
oof = ifft(y);
function [] = morlet_play(fb, fc)


% Set effective support and grid parameters.
lb = -8; ub = 8; n = 1000;

% Compute complex Morlet wavelet cmor1.5-1.
[psi,x] = cmorwavf(lb,ub,n,fb,fc);

% Plot complex Morlet wavelet.
subplot(211)
plot(x,real(psi)),
title('Complex Morlet wavelet cmor1.5-1')
xlabel('Real part'), grid
subplot(212)
plot(x,imag(psi))
xlabel('Imaginary part'), grid
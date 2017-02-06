function [gb] = gabor_1D(t, t0, w0, s)

gb = 1/(s*sqrt(2*pi))*exp(-0.5*(s^-2)*(t-t0).^2).*exp(2*pi*1i*w0*t);
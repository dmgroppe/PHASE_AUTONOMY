function [yhat] = gauss_fit(b, X)

v = b(1);
m = 0;
c = b(2);

yhat = 1/sqrt(2*pi*v)*exp(-(X-m).^2/(2*v)) + c;

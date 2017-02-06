function [yhat] = gauss_fit(b, X)

v = b(1);
m = b(2);
c = b(3);

yhat = 1/sqrt(2*pi*v)*exp(-(X-m).^2/(2*v)) + c;

function [y] = powerfun(b,X)
% den = 1+(X/b(2)).^b(3);
% y = b(1)./den;

den = X.^b(2);
y = b(1)./den;

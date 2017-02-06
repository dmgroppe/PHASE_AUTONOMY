function [yhat] = d_fit(b,X)

yhat = b(1)*exp(-X./b(2))+b(3);
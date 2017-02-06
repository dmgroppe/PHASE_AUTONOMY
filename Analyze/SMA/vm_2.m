function yhat = vm_2(b,X)

% b1 - amplitude of the distribution
% b2 - mean of the distribution
% b3 - kappa of the distribution

yhat1 = b(1)*von_mises_pdf(X,b(2), b(3));
yhat2 = b(4)*von_mises_pdf(X,b(5), b(6));

yhat = yhat1 + yhat2;

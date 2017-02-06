function yhat = vm_1b(b,X)

% b1 - amplitude of the distribution
% b2 - mean of the distribution
% b3 - kappa of the distribution
% b4 - baseline shift

yhat = b(1)*von_mises_pdf(X,b(2), b(3)) + b(4);

if max(isnan(yhat)) == 1 || max(isinf(yhat)) == 1
    yhat = 0;
end
function yhat = cos_fit(b,X)

% b1 - amplitude of the distribution
% b2 - mean of the distribution
% b3 - kappa of the distribution


yhat = b(1) + b(2)*cos(X);

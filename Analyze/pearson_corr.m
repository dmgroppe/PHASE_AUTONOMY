function [r] = pearson_corr(x1, x2)

%   Pearson cross correlation between two signals
%   x1 = signal 1
%   x2 = signal 2

% They must both have the same number of samples

if (length(x1) ~= length(x2))
    r = 0;
    return;
end

%x1diff = x1-mean(x1);
%x2diff = x2-mean(x2);

x1diff = x1-tv_mean(x1);
x2diff = x2-tv_mean(x2);

r = sum(x1diff.*x2diff)/sqrt(sum(x1diff.^2)*sum(x2diff.^2));

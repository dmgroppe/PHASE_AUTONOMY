function [d] = cluster_test(nchan, nperm)

% nchan = 32;
% nperm = 1000;

d = 0;
for i=1:nperm
    order = randperm(nchan);
    d(i) = sum(diff(order));
end
[n,xout] = hist(d,100);
pdf = n/nperm;
cdf = cumsum(pdf);

plot(xout,pdf, xout, cdf);


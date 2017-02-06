function [x1sub x2sub] = twofreq_xmap(x1, x2, window)

xp1 = abs(hilbert(x1));
xp2 = abs(hilbert(x2));

inds = 1:window:length(x1);

ranges = [inds(1:end-1)' (inds(2:end)'-1)];
x1sub = zeros(1,length(ranges));
x2sub = x1sub;

for i = 1:length(ranges)
    x1sub(i) = mean(xp1(ranges(i,1):ranges(i,2)));
    x2sub(i) = mean(xp2(ranges(i,1):ranges(i,2)));
end

h = figure(1);
plot(x1sub, x2sub, '.', 'LineStyle', 'None', 'MarkerSize', 15);
[rho, pval] = corr(x1sub',x2sub', 'type', 'Spearman');
legend(sprintf('rho = %e, p = %e', rho, pval));







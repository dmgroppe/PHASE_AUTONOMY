function [] = clfrange_summary(R)

n = numel(R);
rs = [];
for i=1:n
    if numel([R{i}(:).clfrange]) == 6
        rs = [rs R{i}(3).clfrange'];
    end
end

m = mean(mean(rs));
s = std(mean(rs));
sem = s/sqrt(length(rs));

display(sprintf('Stats: %6.2f +/- %6.2f', m, sem));

hist(mean(rs), 4:11);
set(gca, 'TickDir', 'out');
axis square



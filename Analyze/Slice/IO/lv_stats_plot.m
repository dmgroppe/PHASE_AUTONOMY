function [ms sem n] = lv_stats_plot(R, pcolor, ap)

[~, lv_stats_sm] = Lv_collect(R, ap.io.lv_min_n_toplot);
ms = [lv_stats_sm(:).m];
n = [lv_stats_sm(:).n];
sem = [lv_stats_sm(:).std]./[lv_stats_sm(:).n];

boundedline(1:numel(lv_stats_sm),ms,sem, 'Color', pcolor, 'alpha');
if ~isempty(ap.io.lv_axis)
    axis(ap.io.lv_axis);
end

for i=1:numel(n)
    text(i,ms(i)+.01, sprintf('(%d)', n(i)), 'FontSize', 6);
end
function [h] = plot_corr_p_to_f(R, a_cfg)

h = figure;clf
[r c] = rc_plot(length(a_cfg.freqs));
for i=1:length(a_cfg.freqs)
    
    subplot(r,c,i);
    rem = [find(isnan(R.ps) == 1) find(isnan(R.fs) == 1)];
    R.ps(rem) = [];
    R.fs(rem) = [];
    R.freqs(rem) = [];
    ind = find(R.freqs == a_cfg.freqs(i));
    
    plot(R.ps(ind),R.fs(ind), '.', 'MarkerSize', 10, 'LineStyle', 'none');
    xlabel('Normalized power changes', 'FontSize', 7);
    ylabel('Normalized precursor changes', 'FontSize', 7);

    [rho p] = corr(R.ps(ind)', R.fs(ind)', 'type', 'Spearman');
    title(sprintf('%dHz - r = %6.4f, p = %6.2e', a_cfg.freqs(i), rho, p), 'FontSize', 8);
    set(gca, 'FontSize', 7);
    axis square;
    set(gca, 'TickDir', 'out');
end
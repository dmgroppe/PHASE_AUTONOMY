function [] = plot_pfcorr(pc)

cfg = cfg_default();
fs = [];
ps = [];

fs = [];
ps = [];
freqs = [];
for i=1:numel(pc)
    fs = [fs pc{i}.fs];
    ps = [ps pc{i}.ps];
    freqs = [freqs pc{i}.freqs];
end

[r c] = rc_plot(length(cfg.freqs));
for i=1:length(cfg.freqs)
    
    subplot(r,c,i);
    rem = [find(isnan(ps) == 1) find(isnan(fs) == 1)];
    ps(rem) = [];
    fs(rem) = [];
    freqs(rem) = [];
    ind = find(freqs == cfg.freqs(i));
    
    plot(ps(ind),fs(ind), '.', 'MarkerSize', 10, 'LineStyle', 'none');
    axis([-3 3 -3 3]);
    xlabel('Normalized power changes', 'FontSize', 7);
    ylabel('Normalized precursor changes', 'FontSize', 7);

    [rho p] = corr(ps(ind)', fs(ind)', 'type', 'Spearman');
    title(sprintf('%dHz - r = %6.4f, p = %6.2e', cfg.freqs(i), rho, p), 'FontSize', 10);
    set(gca, 'FontSize', 7);
    axis square;
    set(gca, 'TickDir', 'out');
end
function [h] = plot_avg_ch_spec(R,cfg, ch)

% Plo the results of average spectral analyis from PH analysis

n = sum(~cellfun('isempty', R.P_mean));
[r c] = rc_plot(n);

h(1) = figure; clf;
p = 0;
for i=1:R.nchan
    if ~isempty(R.F_mean{i})
        p = p+ 1;
        subplot(r,c,p)
        plot(cfg.freqs, R.F_mean{i});
        title(ch{i}, 'FontSize', 5, 'FontName', 'Times');
        set(gca, 'FontSize', 5, 'FontName', 'Times');
        axis([cfg.freqs(1) cfg.freqs(end) ylim]);
        axis square;
        set(gca, 'TickDir', 'out');
        p_ind = find(R.F_sig{i} == 1);
        hold on;
        plot(cfg.freqs(p_ind),  R.F_mean{i}(p_ind,2), '.r', 'LineStyle', 'none');
        hold off;
        set(gca, 'box', 'off');
    end
end

h(2) = figure; clf;
p = 0;
for i=1:R.nchan
    if ~isempty(R.P_mean{i})
        p = p+ 1;
        subplot(r,c,p)
        pmax = max(max(R.P_mean{i}));
        loglog(cfg.stats.ph_tf_freqs, R.P_mean{i}/pmax);
        text = sprintf('%s(%d)', ch{i}, i);
        title(text, 'FontSize', 5, 'FontName', 'Times');
        set(gca, 'FontSize', 5, 'FontName', 'Times');
        axis([cfg.stats.ph_tf_freqs(1) cfg.stats.ph_tf_freqs(end) 10e-5 1]);
        xval = [1 10 100];
        set(gca, 'XTick', xval);
        set(gca, 'XTickLabel', num2str(xval'), 'XMinorTick', 'on', 'YMinorTick', 'on');
        
        axis square;
        set(gca, 'TickDir', 'out');
        p_ind = find(R.P_sig{i} == 1);
        hold on;
        plot(cfg.stats.ph_tf_freqs(p_ind),  R.P_mean{i}(p_ind,2)/pmax, '.r', 'LineStyle', 'none');
        hold off;
        set(gca, 'box', 'off');
    end
end
function [h] = plot_S(S, cfg, ch)

% Plots the results from the time frequency analysis

n = 0;
for i=1:numel(S);
    if ~isempty(S(i).p_spec)
        n = n+ 1;
    end
end
    
[r c] = rc_plot(n);

h(1) = figure; clf;
p = 0;
for i=1:numel(S)
    if ~isempty(S(i).f_spec)
        p = p+ 1;
        subplot(r,c,p)
        plot(cfg.freqs, S(i).f_spec);
        title(ch{i}, 'FontSize', 5, 'FontName', 'SmallFont');
        set(gca, 'FontSize', 5, 'FontName', 'SmallFont');
        axis([cfg.freqs(1) cfg.freqs(end) ylim]);
    end
end

h(2) = figure; clf;
p = 0;
for i=1:numel(S)
    if ~isempty(S(i).p_spec)
        p = p+ 1;
        subplot(r,c,p)
        semilogy(cfg.stats.ph_tf_freqs, S(i).p_spec);
        title(ch{i}, 'FontSize', 5, 'FontName', 'SmallFont');
        set(gca, 'FontSize', 5, 'FontName', 'SmallFont');
        axis([cfg.stats.ph_tf_freqs(1) cfg.stats.ph_tf_freqs(end) ylim]);
    end
end
function [ax] = re_label_yaxis(sdir, cfg, T, nchan)

% see if there is channel info to be found
R = names_from_bi_index(1, sdir);
ax = [];
if ~isempty(R)
    switch cfg.chtype
        case 'bipolar'
            labels = R.bi_labels;
        case 'monopolar'
            labels = R.m_labels;
    end


    set(gca, 'YTick', 1:numel(labels));
    set(gca, 'YTickLabel', labels, 'FontSize', 5,'FontName','Small fonts', 'TickDir', 'out');
    ax(1) = gca;
    drawnow;
    
    ax(2) = axes('Position', get(gca,'Position'), 'XAxisLocation', 'bottom', 'YAxisLocation', 'right', 'Color', 'none');
    set(ax(2),'Box','off')
    set(ax(2), 'XTick', []);
    set(gca, 'YDir', 'reverse', 'TickDir', 'out');
    set(ax(2), 'YTick', 1:numel(labels), 'FontSize', 5, 'FontName','Small fonts');
    axis([T(1) T(end) -1 nchan+2]);

    %linkaxes(ax, 'xy');
end
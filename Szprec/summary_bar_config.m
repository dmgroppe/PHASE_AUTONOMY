function [new_ax] = summary_bar_config(main_ax)

m_pos = get(main_ax(1), 'Position');
pos_vec = [m_pos(3)+0.1 m_pos(2) .01 m_pos(4)];
new_ax = subplot('Position',pos_vec);
%set(ax, 'Position',[m_pos(3)+0.15 .11 .025 m_pos(4)]);
set(new_ax,'XTick', [], 'YTick', []);
set(new_ax, 'XColor', [1 1 1]);
set(new_ax, 'YColor', [1 1 1]);

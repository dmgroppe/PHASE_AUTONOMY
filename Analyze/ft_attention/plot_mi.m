function [] = plot_mi(mi, T, hfrange, zaxis)

if nargin < 4; zaxis = []; end;

set(gcf, 'Renderer', 'zbuffer');
surf(T, hfrange, mi);
axis([T(1) T(end) hfrange(1) hfrange(end) min(min(mi)), max(max(mi))]);
set(gca, 'YScale', 'log', 'YMinorTick', 'on', 'TickDir', 'out');
yvals = get(gca,'YTickLabel');
set(gca,'YTickLabel',  10.^str2num(yvals));

view(0,90);
shading interp;
xlabel('Time (ms)');
ylabel('Frequency (Hz)');
title('Time resolved CFC');
if ~isempty(zaxis)
    caxis(zaxis);
end

colorbar;
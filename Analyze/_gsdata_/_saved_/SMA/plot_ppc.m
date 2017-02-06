function [] = plot_ppc(x, rho, ap)
% Plot the power-correlation
colormap(jet);
title('Phase-power correlation');
set(gcf,'Renderer','painters')

if strcmp(ap.pl.axis, 'log');
    pfreqs = log10(ap.freqs);
else
    pfreqs = ap.freqs;
end

surf(x,pfreqs,rho); 

if ~isempty(ap.yaxis)
    axis([x(1) x(end) pfreqs(1) pfreqs(end) min(min(rho)) max(max(rho))]);
else
    axis([x(1) x(end) pfreqs(1) pfreqs(end) ap.yaxis]);
end

set_fa_prop(ap);
axis square;

if ~isempty(ap.yaxis)
    caxis(ap.yaxis);
end

shading interp;
view(0,90);
xlabel('Phase difference (radians');
ylabel('Frequency (Hz)');

% Plot the frequency ranges as bars on the side of the graph
if ap.pl.ranges
    if strcmp(ap.pl.axis, 'log')
        plot_ranges(log10(ap.extrema_range), [-pi -pi+0.16], 'horiz', 'patch','w');
    else
        plot_ranges(ap.extrema_range, [-pi -pi+0.16], 'horiz', 'patch','w');
    end
end

if ap.pl.colorbar
    colorbar
    if ~isempty(ap.yaxis);
        caxis(ap.yaxis);
    end
end

if ap.pl.zeroline
%     hold on;
%     plot([0 0],[ap.freqs(1) ap.freqs(2)], 'w');
%     hold off;
end
% USAGE: plot_rho(w, rho)
% Plots the results of the power-correlation analyses

function [] = plot_rho(w, rho)

set(gcf, 'Renderer', 'zbuffer');
ah = axes;
h = surf(w, w, rho);
axis([w(1), w(end),w(1),w(end), min(min(rho)), max(max(rho))]);
shading flat;
set(h, 'EdgeColor', 'none');
view(0,90);
axis equal
set (ah, 'FontName', 'Palatino Linotype');
xlabel('Frequency (Hz)', 'FontName', 'Palatino Linotype');
ylabel('Frequency (Hz)', 'FontName', 'Palatino Linotype');


title(text);
colorbar('FontName', 'Palatino Linotype');
%caxis([-0.5 1]);
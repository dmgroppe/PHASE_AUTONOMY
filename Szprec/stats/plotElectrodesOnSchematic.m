function [] = plotElectrodesOnSchematic(pt_name,r, cmap, pcfg)

% USAGE: plot_on_schematic(pt_name,r, cmap, pcfg)
%
% Plots the electrode values on a schematic.  pcfg needs to have the
% following parameters:
% pcfg.marker_size = 28;
% pcfg.font_size = 8;
% pcfg.font_name =  'Times New Roman';
%
% r     - ranking of channel
% cmap  - color map with same number of elements as r

[bi_numbers] = get_bi_numbers(pt_name);
epos = get_electrode(pt_name);
   
hold on;
plotted = [];
for i=1:length(r)
    chn = bi_numbers(r(i),:);
    [~, a, ~] =  intersect(chn, plotted);
    chn(a) = [];
    for j=1:length(chn)
        pcolor = cmap(i,:);
        plot(epos(chn(j),1), epos(chn(j),2), '.', 'MarkerSize', pcfg.marker_size, 'Color', pcolor);
        text(epos(chn(j),1), epos(chn(j),2), sprintf('%d',i), 'FontSize', pcfg.font_size, 'FontName', pcfg.font_name,...
            'horizontalAlignment', 'center', 'verticalAlignment', 'middle');
        plotted = [plotted chn(j)];
    end
end
hold off;
% colormap(cmap);
% colorbar('YTick', 1:(length(r)+1));
% %colorbar('YTickLabel', num2str(1:(length(pv)+1)));
% colorbar;
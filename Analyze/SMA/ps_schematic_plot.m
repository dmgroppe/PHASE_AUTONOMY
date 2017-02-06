function [] = ps_schematic_plot(avgps, analyzed_list, w, frange, nfig, dosave, ptname)

if nargin < 7; ptname = 'vant'; end;
if nargin < 6; dosave = 0; end;
if nargin < 5; nfig = 1; end;

[schematic, elist] = load_electrode_schematic(ptname);

h = figure(nfig);
show_schematic(schematic);
hold on;

fstart = get_f_index(frange(1), w);
fend = get_f_index(frange(2), w);

vals = avgps(fstart:fend, :, :);
mean_vals = mean(vals, 1);
diff = mean_vals(1,1,:) - mean_vals(1,2,:);
%diff = mean_vals(1,1,:)./mean_vals(1,2,:);
diff = reshape(diff, length(mean_vals), 1);
diff = diff/(max(diff) - min(diff));

vmax = max(diff);
vmin =  min(diff);

%vmax = 0.6;
%vmin = -0.6;


delta = fix((vmax -vmin)*10)/10/6;
for i=1:7
    labels{i} = sprintf('%3.2f', delta*(i-1)+floor(vmin*10)/10);
end

colorbar('YTickLabel', labels);
%caxis([min(diff) max(diff)]);

plot_on_schematic(diff, analyzed_list, elist, [vmin vmax]);

hold off;

if dosave
    fname = sprintf('PS_schematic_plot %4.0f %4.0f', frange(1), frange(2));
    save_figure(h, get_export_path_SMA(), fname);
end


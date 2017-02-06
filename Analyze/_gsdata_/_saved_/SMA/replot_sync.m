function [R Res] = replot_sync(pinc, pdec, sync, alpha, axis_range, roi)

eDir = get_export_path_SMA();

% Plot the square matrix

[sig_inc, pcut_inc] = FDR_corr_pop(pinc, alpha);
[sig_dec, pcut_dec] = FDR_corr_pop(pdec, alpha);
csig = (sig_inc + sig_dec).*abs(sync);

h = figure(1);
plot_syncmatrix(csig, axis_range);
fprintf('\npcut inc = %6.4f, pcut dec = %6.4f\n', pcut_inc, pcut_dec);

save_figure(h, eDir, 'Replot - Square plot');

% Plot on circle

h = figure(2);
axis square;

x = 2*pi/64*(1:64);
coords(:,:) = [sin(x)', cos(x)'];
wgplot(csig, coords, axis_range, 'edgeColorMap', jet, 'edgeWidth',1.5, ...
    'vertexMarker', 'o');
cl = channel_labels();
for i=1:length(csig);
    text(1.06*sin(x(i)), 1.06*cos(x(i)), ['\color{black}' cl{i}],'FontSize',5);
end

save_figure(h, eDir, 'Replot - Weighted graph');

% Plot on schematic

h = figure(3);
[schematic, elist] = load_electrode_schematic();
show_schematic(schematic);


total_sig = sig_inc + sig_dec;
[R] = sort_to_regions(total_sig, roi);

% Find all the channels that are connected
sig_channels = unique(R.all_c);
% Get all channels that are connected to the ROI
connected = unique([R.within_c R.between_c]);
Res.connected_notinroi = remove_channels(connected, roi);
Res.unconnected = remove_channels(R.out_c, Res.connected_notinroi);

fprintf('%d of %d connected electrode are with the ROI.\n', length(connected), length(sig_channels));

d = 60;
for i=1:length(sig_channels)
    ch = sig_channels(i);
    
    if isempty(find(connected == ch, 1))
        fcolor = 'b';
    else
        fcolor = 'r';
    end
    
    rectangle('Position', [elist(1,ch)-d/2, elist(2,ch)-d/2, d, d],...
        'Curvature', [1 1], 'FaceColor', fcolor, 'EdgeColor', 'none');
end

save_figure(h, eDir, 'Replot - schematic');

% find all electrodes connected to roi but not in the roi

outside_roi = setxor(connected, roi);

% Export to pajek for visualization
% fill in the rest of the adjaceny matrix
adjm = total_sig.*sync;
for i=1:length(total_sig)
    for j=i+1:length(total_sig)
%         if adjm(j,i) == 0
%             adjm(j,i) = -1;
%         end
        adjm(i,j) = adjm(j,i);
    end
end
n= length(adjm);
adjm(1:n+1:n*n) = -1;
adj2pajek2(adjm,[eDir 'Replot - adjm']);


function [list] = remove_channels(list, toremove)

for i=1:length(toremove)
    list(find(list == toremove(i))) = [];
end





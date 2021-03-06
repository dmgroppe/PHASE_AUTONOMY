% USAGE: show_sig_channels(prob_summary, analyzed_list, nsig_freq, avgps,
% savefig)
%
% prob_summary: number of significant contiguous points that are
%               significant in a each frequency bandm for each channel
% analyzed_list: the channels that were analyzed
% nsig_freq: number of significant frequencies to consider significant
% avg_ps: averge power spectra for the two conditions  for each channel
% savefig: save the figure

function [] = ps_show_sig_channels(prob_summary, analyzed_list, nsig_freq, avgps, w, savefig)

if nargin < 5; savefig = 0; end;

[schematic, elist] = load_electrode_schematic();
A = analysis_lists();
nfreq = size(A.flist,2);
roi = [7 8 15 16 59 60 61];

h = figure(1);
[ch_sig]= get_sig_channel(prob_summary, analyzed_list, nsig_freq);

sigs = ch_sig;
% Only plot increases, so discard -1s
sigs(find(ch_sig == -1)) = 0;

for i=1:nfreq
    ax(i) = subplot(2,3,i);
    show_schematic(schematic);
    hold on;
    vals = vals_to_plot(A.flist(:,i), avgps, w);
    plot_on_schematic(vals, analyzed_list, elist, [0 fix(max(vals))+1], sigs(i,:));
    %plot_sig_channel(ch_sig, analyzed_list, elist, i, roi);
    title(sprintf('%s %4.0fHz to %4.0fHz', A.fnames{i}, A.flist(1,i), A.flist(2,i)));
end
linkaxes(ax, 'xy');
hold off

if savefig
    save_figure(h, get_export_path_SMA(), 'Power distributions');
end

function [] = plot_sig_channel(ch_sig, analyzed_list, elist, freq, roi)

d = 60;

for i=1:length(ch_sig)
    if (ch_sig(freq,i)~= 0)
        ch = analyzed_list(i);
        if (isempty(find(ch == roi, 1)))
            if ch_sig(freq,i) > 0
                fcolor = 'b';
            else
                fcolor = [255 165 0]/255;
            end
        else
            fcolor = 'r';
        end
        rectangle('Position', [elist(1,ch)-d/2, elist(2,ch)-d/2, d, d],...
                  'Curvature', [1 1], 'FaceColor', fcolor, 'EdgeColor', 'none');
    end
end


function [ch_sig]= get_sig_channel(prob_summary, analyzed_list, nsig_freq)

[nfreq, ~] = size(prob_summary);

for j=1:nfreq
    for i=1:length(analyzed_list)
        if (abs(prob_summary(j,i)) >= nsig_freq)
            ch_sig(j,i) = sign(prob_summary(j,i));
        else
            ch_sig(j,i) = 0;
        end
    end
end

function [vals] = vals_to_plot(frange, avgps, w)

fstart = get_f_index(frange(1), w);
fend = get_f_index(frange(2), w);

vals = avgps(fstart:fend, :, :);
mean_vals = mean(vals, 1);
%diff = mean_vals(1,1,:) - mean_vals(1,2,:);
diff = mean_vals(1,1,:)./mean_vals(1,2,:)-1;
diff = reshape(diff, length(mean_vals), 1);
%vals = diff/(max(diff) - min(diff));
vals = diff;


function [all_features] = spike_summary(R, alist, dosave)

global FIGURE_DIR;

if nargin < 3; dosave = false; end;

eDir = FIGURE_DIR;

ap = sl_sync_params();

% Keep track of th efigures for printing
fcount = 0;
figs = [];
clc

display('------------------ SPIKE SUMMARY ------------------------------');
[bigger smaller excl] = stats_2nd_spike(R, alist);
fprintf('\n2nd spike larger = %d cells, 2nd spike smaller = %d cells, excluded = %d cells\n', ...
    numel(bigger), numel(smaller), numel(excl));
% Iterate over the broad categories of cells

% Display the filename in the two sets
display('Files for Second SMALLER than first:')
print_file_names(smaller);

display('Files for Second BIGGER than first:')
print_file_names(bigger);


% ISIs STATS
[fcount, figs] = figure_set(fcount, figs, 'ISI stats for second SMALLER than first spike');
isi_summary(smaller, ap);

[fcount, figs] = figure_set(fcount, figs, 'ISI stats for second BIGGER than first spike');
isi_summary(bigger, ap);

% LV STATS

[fcount, figs] = figure_set(fcount, figs, 'LV STATS');
[m sem n] = lv_stats_plot(smaller, [0 0 1], ap);
hold on;
[m sem n] = lv_stats_plot(bigger, [0 1 0], ap);
legend({'Smaller', 'Bigger'});
axes_my_defaults();

% SPIKE feature STATS

display('---------- STATS for second SMALLER -----------------');
[fcount, figs] = figure_set(fcount, figs, 'Second spike SMALLER than first');
[all_features,~] = feature_summary(smaller, ap);
[M V N] = plot_features(all_features,ap.io.firstspikestodisp, ap.io.features, ap.io.normalize);
features_stats(all_features,ap);

display('---------- STATS for second BIGGER -----------------');
[fcount, figs] = figure_set(fcount, figs, 'Second spike BIGGER than first');
[all_features,~] = feature_summary(bigger, ap);
plot_features(all_features,ap.io.firstspikestodisp, ap.io.features, ap.io.normalize);
features_stats(all_features,ap);

% --------------------  DATA Summaries -----------------------------------%

[r c] = rc_plot(length(alist));
[fcount, figs] = figure_set(fcount, figs, 'Spike ISI Summaries');
for i=1:length(alist)
    subplot(r,c,i);
    
    ind = alist(i);
    
    plot_isi(R(ind).S, R(ind).mp, ap);
    title(R(ind).fname, 'FontSize', 7);
    set(gca, 'FontSize', 6);
end

[fcount, figs] = figure_set(fcount, figs, 'Spike Amplitude Summaries');
for i=1:length(alist)
    subplot(r,c,i);
  
    ind = alist(i);
 
    plot_amplitudes(R(ind).S);
    title(R(ind).fname, 'FontSize', 7);
    set(gca, 'FontSize', 6);
end

% Save for making figures
if dosave
    display('Saving all figures...')
    for i=1:fcount
        save_figure(figs(i).h, eDir, figs(i).name);
    end
end

%  Grouping of cells according to some criteria

% --------------------------------  PLOT function ----------------------%

function [] = plot_spikes(all_spikes, nspikes)

for i=1:nspikes
    subplot(nspikes,1,i)
    ind = find(all_spikes.sp_number == i);
    hold on;
    for j=1:length(ind)
        s = ind(j);
        t = (0:length(all_spikes.sp{s})-1)/all_spikes.sr(s)*1e3;
        plot(t, all_spikes.sp{s});
    end
    hold off;
end

function [] = plot_isi(S, mp, ap)

nepisodes = numel(S.pks);
cmap = colormap(lines);
ccount = 0;

for j = 1:nepisodes
    hold on;

    % Subtract off the resting membrane potential
    if ~isempty(S.pks{j})
        S.pks{j} = S.pks{j}- mp.resting;
    end

    if ~(length(S.locs{j}) < ap.io.minspikes) && (min(S.T(S.locs{j}))< ap.io.maxT)
        ccount = ccount + 1;
        ISI = diff(S.T(S.locs{j}));
        plot(ISI, 'Color',cmap(ccount,:));
    end 
end




function [] = plot_amplitudes(S)
nepisodes = numel(S.pks);
cmap = colormap(lines);
ccount = 0;

for j = 1:nepisodes
    hold on;
    if ~isempty(S.pks{j})
        ccount = ccount + 1;
        plot(S.pks{j}, 'Color',cmap(ccount,:));
    end 
end

function [all_spikes] = collapse_spikes(S, SR)

count = 0;
for i=1:numel(S)
    for j= 1:numel(S{i})
        if ~isempty(S{i}{j})
            for k=1:numel(S{i}{j})
                count = count + 1;
                all_spikes.sp{count} = S{i}{j}{k};
                all_spikes.sp_number(count) = k;
                all_spikes.sr(count) = SR{i}{j}{k};
            end
        end
    end
end

function [fcount, figs] = figure_set(fcount, figs, fname)
fcount = fcount + 1;
figs(fcount).h = figure(fcount);
figs(fcount).name = fname;
set(figs(fcount).h, 'Name', figs(fcount).name)
clf;

function [] = print_file_names(R)
for i=1:numel(R)
    display(R(i).fname);
end




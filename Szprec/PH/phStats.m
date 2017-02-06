function [R] = phStats(sz_names, atype, a_cfg, dosave)

global DATA_PATH;

if nargin < 4; dosave = 1; end;
if nargin < 3; a_cfg = cfg_default(); end;
if nargin <2;
    atype = 'early';
end

a_cfg.use_fband = false;
c = 0;

for i=1:numel(sz_names)
    pt_name = strtok(sz_names{i}, '_');
    results_path = Szprec_ph_data_path(a_cfg, sz_names{i}, atype);
    results_file = fullfile(results_path, [sz_names{i} '-PH.mat']);

    if ~exist(results_file, 'file')
        display(results_file)
        display('Could not be found.')
        return;
    else
        c = c + 1;
        load(results_file);
        all_R{c} = R;
    end
end


[channels, ~] = get_channels_with_text(pt_name, [], 'bipolar');
nchan = numel(channels);

for i=1:nchan
    if ~isempty(strfind(channels{i}, 'GRID'))
        new_names{i} = sprintf('%s(%d,%d)', channels{i},i,ceil(i/7));
    else
        new_names{i} = sprintf('%s(%d)', channels{i}, i);
    end
end

channels = new_names;
ch_locs = cell(1,nchan);
n_sz = zeros(1,nchan);
mean_loc = n_sz;

% Compute the Z-value for the onset times

ch_locs = zeros(numel(all_R), nchan)*NaN;

for i=1:nchan
    for j=1:numel(all_R)
        ch_locs(j,i) = (all_R{j}.loc(i)-nanmin(all_R{j}.loc))/all_R{j}.srate;
    end
    n_sz(i) = sum(~isnan(ch_locs(:,i)));
    mean_loc(i) = nanmedian(ch_locs(:,i));
    if n_sz(i) <= a_cfg.stats.min_sz
        mean_loc(i) = NaN;
    end
end

% Compute Cohen's Kappa to see if the disctribution of the rankings is
% by chance, or consistent across seizures (may no tbe the bets way to do
% this).  Does not seem ideal for few number of seizures, although
% consistent ranking.

[~, s_ind] = sort(ch_locs');
for i=1:nchan
    for j=1:nchan
        c(i,j) = sum(s_ind(j,:) == i);
    end
end
k = kappa(c);

% Compute the deviations from group mean
plot_values = (mean_loc-nanmedian(mean_loc))/iqr(mean_loc);
plot_values = plot_values(:);
n_sz = n_sz(:);
n_ind = find(isnan(plot_values) == 0);

% Compute the individual normalized times in a single line
%r = bsxfun(@rdivide, bsxfun(@minus, ch_locs, mean_loc), iqr(ch_locs));
%% Plot the results 

h = figure; clf;
set(h, 'Name', sprintf('%s - Page-Hinkley summary %s', pt_name, upper(atype)));
subplot(1,2,1);
val_with_labels(plot_values(n_ind), channels(n_ind), n_sz(n_ind));

subplot(1,2,2);
[~, ind] = sort(plot_values);
p_pv = plot_values(ind);
p_ch = channels(ind);
for i=1:length(channels)
    sorted_ch_names{i} = sprintf('(%d)%s',i,p_ch{i});
end
p_ch = sorted_ch_names;

p_n_sz = n_sz(ind);
n_ind = find(isnan(p_pv) == 0);

val_with_labels(p_pv(n_ind), p_ch(n_ind), p_n_sz(n_ind), 1);
xlabel('Weighted deviation from group average time (s).', 'FontSize', 10,'FontName','Times');
title(sprintf('kappa = %4.2f, p = %6.4f', k.k, k.p));


% Normalization to 1
%plot_values = plot_values-min(plot_values);
%plot_values = plot_values/max(plot_values);


%% Summarize the sorted channel times for all the seizures
h = figure;clf;
set(h, 'Name', sprintf('%s - Individual seizure times', pt_name));

[r,c] = rc_plot(numel(all_R));

max_ind = -1;
for i=1:numel(all_R)
    p_loc = all_R{i}.loc/all_R{i}.srate-nanmedian(all_R{i}.loc/all_R{i}.srate);
    ind = find(isnan(p_loc) == 0);
    p_loc = (p_loc-nanmedian(p_loc))/iqr(p_loc(ind)); % Key normalization
    [~,s_ind] = sort(p_loc,'ascend');
    n_loc(:,i) = s_ind;
    ax(i) = subplot(r,c,i);
    val_with_labels(p_loc(s_ind), channels(s_ind), n_sz, 0);
    max_ind = max([max_ind max(find(isnan(p_loc(s_ind)) ~= 1))]);
    szname = sz_names{i};
    szname(find(szname == '_')) = '-';
    title(upper(szname));
    set(gca, 'box', 'off');
end
linkaxes(ax, 'xy');
ylim([0  max_ind+1]);


%% Correlate to the clinical findings if available
% clinical = clinical_summary(pt_name);
% if ~isempty(clinical)
%     nsum = 0;
%     for i=1:numel(all_R)
%         ind = find_text({clinical.sz_names}, sz_names{i});
%         if ind
%             nsum = nsum + 1;
%             for j=1:length(n_loc)
%                 ch_name = channels(n_loc(j,i)); % Names in ranked order
%                 t = textscan(ch_name, '%s', 'Delimiter', '1234567890-');
%                 text{1} = clinical(ind).summary;
%                 text{2} = t{1};
%                 [nfind, ind, words] = scan_text(text);
%             end
%         end
%     end
% end


%% Create the results structure and save it

R = struct_from_list('n_sz', n_sz, 'plot_values', plot_values, 'sz_names', sz_names,...
    'mean_loc', mean_loc, 'ch_locs', ch_locs);


if a_cfg.use_fband
    subdir = '\Processed\Bipolar_FBAND';
else
    subdir = '\Processed\Adaptive deriv';
end

summary_file = fullfile(DATA_PATH, 'Szprec', pt_name, subdir,...
        [pt_name '_PH_Summary_' atype '.mat']);
    
if dosave
    save(summary_file, 'R');
end

function [] = val_with_labels(plot_values, channels, n_sz, plot_nsz)
if nargin < 4; plot_nsz = 0; end;

barh(plot_values);
set(gca, 'YDir', 'reverse', 'TickDir', 'out');
set(gca, 'YTick', 1:numel(channels));
set(gca, 'YTickLabel', channels, 'FontSize', 7,'FontName','Small fonts');
axis([xlim 0 numel(channels)+1]);

if plot_nsz
    text_loc = max(xlim)+max(xlim)/10;
    hold on;
    for i=1:numel(channels)
        text(text_loc, i, sprintf('%d', n_sz(i)), 'FontSize', 7,'FontName','Small fonts');
    end
    hold off;
end



function [] = Szprec_stats1(sz_name, plot_fig)

global DATA_PATH;

if nargin < 2; plot_fig = 0; end;

a_cfg = cfg_default();
pt_name = strtok(sz_name, '_');
tcond = a_cfg.stats.tcond;

suffix = '_F\';
fpath = make_file_name(DATA_PATH, sz_name, 'Adaptive deriv', suffix);
F_file = fullfile(fpath, ['All freqs - ' sz_name suffix(1:end-1) '.fig']);

suffix = '_F_FBAND\';
fpath = make_file_name(DATA_PATH, sz_name, 'Bipolar_FBAND', '_F_FBAND\');
Fband_file = fullfile(fpath, [sz_name suffix(1:end-1) '.mat']);

if ~exist(Fband_file, 'file')
    display(Fband_file);
    error('Data file not found');
end

if exist(F_file, 'file') && plot_fig
    open(F_file);
    % [rank, f_out] = Szprec_rank(F,cfg, a_cfg, pt_name);
    % plot_f(f_out,matrix_bi,rank,Sf,cfg,pt_name, 5);
end


[~,ind1] = get_channels_with_text(pt_name, tcond{1}, 'bipolar');
[~,ind2] = get_channels_with_text(pt_name, tcond{2}, 'bipolar');

if isempty(ind1) || isempty(ind2)
    display('Could not find channels with specified names');
    return;
end

h = figure(1);clf;
set(h, 'Name', sz_name);

load(Fband_file);

% Compute total value of F for each channel and then rank the channels -
% did not work so well, I guess since this is a dynamic process.

[ch_sorted, ~, ch_ranked_labels ch_sum] = rank_cum_sum(F{1}, pt_name, 'bipolar');

npoints = length(F{1});
M(:,1) = mean(F{1}(:,ind1),2);
M(:,2) = mean(F{1}(:,ind2),2);
m = cumsum(M(:,1)-M(:,2));
t = (0:(npoints-1))/Sf;

% Compute the p-values
display('Computing surrogates...');
[surr p_ind] = permute_precursor(m, M(:,1), M(:,2), a_cfg);
surr_mean = squeeze(mean(surr(:,:,1),2));


%plot the precursor values
ax(1) = subplot(3,3,[1 2]);
plot(t,M(:,1), t, M(:,2));
axis([t(1) t(end) min(min(M)) max(max(M))]);
legend(tcond, 'Location', 'NorthWest');
title('Average precursor values');
axes_text_style(gca);

% Correlate the two time series
subplot(3,3,3);
plot(M(:,1), M(:,2), '.k', 'LineStyle', 'none', 'MarkerSize', 2);
axis([min(M(:,1)) max(M(:,1)) min(M(:,2)) max(M(:,2))]);
xlabel(tcond{1});
ylabel(tcond{2});
[r p] = corr(M(:,1), M(:,2), 'type', 'Spearman');
title(sprintf('r=%6.2e,p=%6.2e',r, p));
axes_text_style(gca);


% Plot the metric
ax(2) = subplot(3,3,[4 5]);
plot(t, m);
axis([t(1) t(end) ylim]);
title(sprintf('Difference of cumsum of %s-%s', tcond{1}, tcond{2}));
axes_text_style(gca);
hold on;
plot(t,surr_mean, 'm');
hold off;
legend({'sum', 'surr'});
if ~isempty(p_ind)
    hold on;
    plot(t(p_ind), m(p_ind), '.r', 'MarkerSize', 3);
    hold off;
end
linkaxes(ax, 'x');

subplot(3,3,6);
hist(m - surr_mean);

subplot(3,3,7);
barh(z_mat(ch_sorted));
set(gca, 'YTick', 1:length(ch_ranked_labels));
set(gca, 'YTickLabel', ch_ranked_labels, 'FontSize', 5);
title('Z-scored sumed precursor values');
axis([xlim 1 length(ch_ranked_labels)]);
axes_text_style(gca,5);

subplot(3,3,8);
m1 = mean(ch_sum(ind1));
sem1 = std(ch_sum(ind1))/sqrt(numel(ind1));
m2 = mean(ch_sum(ind2));
sem2 = std(ch_sum(ind2))/sqrt(numel(ind2));
[p,~] = ranksum(ch_sum(ind1), ch_sum(ind2));
barweb([m1,m2]',[sem1,sem2]', 0.5, tcond);
title(sprintf('p = %6.4f', p));


% Plot correlation between surrogates and mean precursor values
subplot(3,3,9);
plot(surr_mean, m, '.k', 'LineStyle', 'none', 'MarkerSize', 2);
axis([min(surr_mean) max(surr_mean) min(m) max(m)]);
xlabel('Surrogate');
ylabel('Precursor');
[r p] = corr(surr_mean, m, 'type', 'Spearman');
title(sprintf('r=%6.2e,p=%6.2e',r, p));
axes_text_style(gca);

%% Functions

function [fname] = make_file_name(DATA_PATH, sz_name, folder, suffix)
pt_name = strtok(sz_name, '_');
fname = fullfile(DATA_PATH, 'Szprec',  pt_name, 'Processed', folder,...
        [sz_name suffix]);
    
function [cs, p_ind] = permute_precursor(m, x1, x2, cfg)
npoints = length(x1);

% Generate the surrogates
%[s1,~]=IAAFT(x1,cfg.stats.nsurr,cfg.stats.maxiter);
%[s2,~]=IAAFT(x2,cfg.stats.nsurr,cfg.stats.maxiter);

cs = zeros(npoints,cfg.stats.nsurr);
for i=1:cfg.stats.nsurr
    cs(:,i) = cumsum(rand_rotate(x1)-rand_rotate(x2));
end

m_mat = repmat(m,1,cfg.stats.nsurr);
p = sum((m_mat < cs(:,:,1)),2)/cfg.stats.nsurr;
p_ind = (p <= cfg.stats.alpha);

p_ind = p_ind | ((1-p) <=  cfg.stats.alpha);
p_ind = find(p_ind == 1);



function [] = plot_sig(t,y, p_ind, lspec)
if ~isempty(p_ind)
    hold on;
    plot(t(p_ind), y(p_ind), lspec, 'MarkerSize', 5);
    hold off;
end


function [sorted, ch_rank, ranked_labels csum] = rank_cum_sum(F, pt_name, ch_type)
[npoints, nchan] = size(F);

for i=1:nchan
    csum(i) = sum(squeeze(F(:,i)));
end
[sorted, ch_rank] = sort(csum, 'descend');

% Get the labels for this patient
[ch_labels, ~] = get_channels_with_text(pt_name, [], ch_type);

for i=1:nchan
    ranked_labels{i} = ch_labels{ch_rank(i)};
end





    






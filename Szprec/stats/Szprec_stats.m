function [] = Szprec_stats(sz_name, plot_fig)

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

% [~, ~, ranked_labels] = rank_cum_sum(F{1}, pt_name, 'bipolar');
% ranked_labels

npoints = length(F{1});
M(:,1) = mean(F{1}(:,ind1),2);
M(:,2) = mean(F{1}(:,ind2),2);
m = cumsum(M(:,1)-M(:,2));
t = (0:(npoints-1))/Sf;

% Compute the p-values
display('Computing surrogates...');
[surr p1_ind p2_ind] = permute_precursor(m, M(:,1), M(:,2), a_cfg);
p_intersect = intersect(p1_ind, p2_ind);


%plot the precursor values
ax(1) = subplot(3,1,1);
plot(t,M(:,1), t, M(:,2));
axis([t(1) t(end) min(min(M)) max(max(M))])
legend(tcond, 'Location', 'NorthWest');
title('Average precursor values');
axes_text_style();


% Plot the metric
ax(2) = subplot(3,1,2);
plot(t, m);
title(sprintf('Difference of cumsum of %s-%s', tcond{1}, tcond{2}));
axes_text_style();
hold on;
plot(t,squeeze(mean(surr(:,:,1),2)), 'm');
plot_sig(t,m,p1_ind, '.g');
hold off;
legend({'sum', sprintf('%s rot', tcond{1}) ...
    sprintf('%s rot sig', tcond{1})}, 'Location', 'NorthWest');
axis([t(1) t(end) ylim]);
if ~isempty(p_intersect)
    hold on;
    plot_sig(t,m,p_intersect, '.y');
    hold off;
end

% Plot the metric
ax(3) = subplot(3,1,3);
plot(t, m);
title(sprintf('Difference of cumsum of %s-%s', tcond{1}, tcond{2}));
axes_text_style();
hold on;
plot(t,squeeze(mean(surr(:,:,2),2)), 'm');
plot_sig(t,m,p2_ind, '.g');
hold off;
legend({'sum', sprintf('%s rot', tcond{2}),sprintf('%s rot sig', tcond{2})},...
    'Location', 'NorthWest');
axis([t(1) t(end) ylim]);
if ~isempty(p_intersect)
    hold on;
    plot_sig(t,m,p_intersect, '.y');
    hold off;
end

% % Plot the p-values
% ax(3) = subplot(3,1,3);
% plot(t,p, t, 1-p);
% axis([t(1) t(end) 0 1]);
% title(sprintf('P'));
% axes_text_style();
% legend({'P_d_a_t_a > surrogates','P_d_a_t_a < surrogates'},'Location', 'NorthWest');

linkaxes(ax, 'x');


function [fname] = make_file_name(DATA_PATH, sz_name, folder, suffix)
pt_name = strtok(sz_name, '_');
fname = fullfile(DATA_PATH, 'Szprec',  pt_name, 'Processed', folder,...
        [sz_name suffix]);
    
function [cs, p1_ind,p2_ind] = permute_precursor(m, x1, x2, cfg)
npoints = length(x1);

% Generate the surrogates
%[s1,~]=IAAFT(x1,cfg.stats.nsurr,cfg.stats.maxiter);
%[s2,~]=IAAFT(x2,cfg.stats.nsurr,cfg.stats.maxiter);

cs = zeros(npoints,cfg.stats.nsurr);
for i=1:cfg.stats.nsurr
    %cs(:,i,1) = cumsum(s1(:,i)-s2(:,i));
    %cs(:,i,1) = cumsum(rand_rotate(x1)-rand_rotate(x2));
    %cs(:,i,1) = cumsum(rand_rotate(x1)-x2(:)');
    cs(:,i,1) = cumsum(rand_rotate(x1)-rand_rotate(x2));
    cs(:,i,2) = cumsum(rand_rotate(x1)-rand_rotate(x2));
end

m_mat = repmat(m,1,cfg.stats.nsurr);
m1_less = (m_mat < cs(:,:,1));
m2_less = (m_mat < cs(:,:,2));

p1 = sum(m1_less,2)/cfg.stats.nsurr;
p2 = sum(m2_less,2)/cfg.stats.nsurr;
p1_ind = (p1 <= cfg.stats.alpha);
p2_ind = (p2 <= cfg.stats.alpha);

p1_ind = p1_ind | ((1-p1) <=  cfg.stats.alpha);
p1_ind = find(p1_ind == 1);

p2_ind = p2_ind | ((1-p2) <=  cfg.stats.alpha);
p2_ind = find(p2_ind == 1);




function [] = plot_sig(t,y, p_ind, lspec)
if ~isempty(p_ind)
    hold on;
    plot(t(p_ind), y(p_ind), lspec, 'MarkerSize', 5);
    hold off;
end


function [sorted, ch_rank, ranked_labels] = rank_cum_sum(F, pt_name, ch_type)
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



    






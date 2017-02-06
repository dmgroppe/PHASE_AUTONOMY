function [R_summary] = spec_stats_summary(pt_names, bl_type, save_figs)

% Function summarizes power and FV increases and decreases on a per channel
% basis across all analyzed subjects listed in ptnames.  Takes the results
% of 'spec_stats' function to accomplish this.

global DATA_PATH;
global FIGURE_DIR;

a_cfg = cfg_default();

if nargin < 2; bl_type = 'pre'; end;
if nargin < 3; save_figs = 0; end;
handles = [];

switch bl_type
    case 'pre'
        subdir = 'Ph_stats_pre';
    case 'start'
        subdir = 'Ph_stats_start';
end

% Read in all the results from the TF analysis
for i=1:numel(pt_names)
    pfstats_file = fullfile(make_data_path(pt_names{i}, 'processed_dir'), subdir, [pt_names{i} '_PFSTATS.mat']);
    
    if exist(pfstats_file, 'file')
        load(pfstats_file);
        R(i) = struct_from_list('pfcorr', pfcorr, 'spec_means',spec_means, 'a_cfg', a_cfg, ...
            'ch', ch, 'pt_name', pt_name);
    else
        display(pfstats_file);
        display('File not found...');
        return;
    end
end

% Get the results from the spec_stats analysis and collect in R_ss
for i=1:numel(R)
    [R_ss(i), ~]  = spec_stats(R(i).spec_means, a_cfg,0);
end


% Count various things
for i=1:numel(R_ss)
    pf_sum(i,:) = R_ss(i).pf_sum;
    nchan(i) = R_ss(i).no_onset + R_ss(i).onset;
    nsig_p_freq (:,1,i) = R_ss(i).nsig_p_freq_inc;
    nsig_p_freq (:,2,i) = R_ss(i).nsig_p_freq_dec;
    
    nsig_f_freq (:,1,i) = R_ss(i).nsig_f_freq_inc;
    nsig_f_freq (:,2,i) = R_ss(i).nsig_f_freq_dec;
end

% ------------Power summary
cm_blue = cbrewer('seq', 'Blues', length(a_cfg.stats.ph_tf_freqs));
cm_red = cbrewer('seq', 'Reds', length(a_cfg.stats.ph_tf_freqs));

h(1) = figure; clf;
fname = sprintf('%s_Spec_stats_summary_%s - POWER INCREASE',pt_name, upper(bl_type));
set(h(1), 'name', fname);
handles = add_fig_h(handles, h(1), fname);



% Set up the color bar YLabels
[f, f_ind,~] = intersect(a_cfg.stats.ph_tf_freqs, a_cfg.freqs);
f(end+1) = a_cfg.stats.ph_tf_freqs(end);
f_ind(end+1) = length(a_cfg.stats.ph_tf_freqs);

% compute fractions by dividing number of channels for each patient
nsig_p_freq_frac = bsxfun(@rdivide, squeeze(nsig_p_freq(:,1,:)), nchan);
plot_nsig_freqs(pt_names, nsig_p_freq_frac', f_ind,f, cm_red); % plot increases
title('Significant power increases', 'FontName', 'Times New Roman');
axis([xlim 0 0.5]);


h(2) = figure; clf;
fname = sprintf('%s_Spec_stats_summary_%s - POWER DECREASE',pt_name, upper(bl_type));
set(h(2), 'name', fname);
handles = add_fig_h(handles, h(2), fname);

nsig_p_freq_frac(:,:,2) = bsxfun(@rdivide, squeeze(nsig_p_freq(:,2,:)), nchan);
plot_nsig_freqs(pt_names, nsig_p_freq_frac(:,:,2)', f_ind, f, cm_blue); % plot increases
title('Significant power decreases', 'FontName', 'Times New Roman');
axis([xlim 0 0.5]);


% --------------------FV summary
cm_blue = cbrewer('seq', 'Blues', length(a_cfg.freqs));
cm_red = cbrewer('seq', 'Reds', length(a_cfg.freqs));

h(3) = figure; clf;
fname = sprintf('%s_Spec_stats_summary_%s - FA INCREASE',pt_name, upper(bl_type));
set(h(3), 'name', fname);
handles = add_fig_h(handles, h(3), fname);


f_ind = 1:length(a_cfg.freqs);
nsig_f_freq_frac = bsxfun(@rdivide, squeeze(nsig_f_freq(:,1,:)), nchan);
plot_nsig_freqs(pt_names, nsig_f_freq_frac', f_ind, a_cfg.freqs, cm_red); % plot increases
title('Significant FV increases', 'FontName', 'Times New Roman');
axis([xlim 0 1]);

h(4) = figure; clf;
fname = sprintf('%s_Spec_stats_summary_%s - FA DECREASE',pt_name, upper(bl_type));
set(h(4), 'name', fname);
handles = add_fig_h(handles, h(4), fname);

nsig_f_freq_frac(:,:,2) = bsxfun(@rdivide, squeeze(nsig_f_freq(:,2,:)), nchan);
plot_nsig_freqs(pt_names, nsig_f_freq_frac(:,:,2)', f_ind, a_cfg.freqs, cm_blue); % plot increases
title('Significant FV decreases', 'FontName', 'Times New Roman');
axis([xlim 0 1]);

% Plot average increases and decreases of power and FV and do stats across patients

for i=1:length(a_cfg.stats.ph_tf_freqs)
    p_p_inc(i) = signtest(squeeze(nsig_p_freq_frac(i,:,1)));    
    p_p_dec(i) = signtest(squeeze(nsig_p_freq_frac(i,:,2)));
end

for i=1:length(a_cfg.freqs)
    p_f_inc(i) = signtest(squeeze(nsig_f_freq_frac(i,:,1)));
    p_f_dec(i) = signtest(squeeze(nsig_f_freq_frac(i,:,2)));
end

% FDR correct the stats
p_inc_sig = fdr_vector(p_p_inc,a_cfg.stats.alpha,0);
p_dec_sig = fdr_vector(p_p_dec,a_cfg.stats.alpha,0);

f_inc_sig = fdr_vector(p_f_inc,a_cfg.stats.alpha,0);
f_dec_sig = fdr_vector(p_f_dec,a_cfg.stats.alpha,0);


h(4) = figure; clf;
fname = sprintf('%s_Spec_stats_summary_%s - POWER FV Fraction changes',pt_name, upper(bl_type));
set(h(end), 'name', fname);
handles = add_fig_h(handles, h(end), fname);

subplot(2,1,1);
p_inc = median(squeeze(nsig_p_freq_frac(:,:,1)),2);
p_dec = median(squeeze(nsig_p_freq_frac(:,:,2)),2);

plot_nsig_averages(p_inc, iqr(squeeze(nsig_p_freq_frac(:,:,1)),2), p_inc_sig, ...
    p_dec, iqr(squeeze(nsig_p_freq_frac(:,:,2)),2), p_dec_sig, a_cfg.stats.ph_tf_freqs);

subplot(2,1,2);
f_inc = median(squeeze(nsig_f_freq_frac(:,:,1)),2);
f_dec = median(squeeze(nsig_f_freq_frac(:,:,2)),2);

plot_nsig_averages(f_inc, iqr(squeeze(nsig_f_freq_frac(:,:,1)),2), f_inc_sig, ...
    f_dec, iqr(squeeze(nsig_f_freq_frac(:,:,2)),2), f_dec_sig, a_cfg.freqs);

% Stats on number of channels
% Summarize the key stats
% pf_sum(1) = onset/sm.nchan;  
% pf_sum(2) = nsig_p_chan/sm.nchan;
% pf_sum(3) = nsig_f_chan/sm.nchan;
% 
% n_p_and_f = numel(intersect(sig_p_chan, sig_f_chan));
% pf_sum(4) =  n_p_and_f/nsig_f_chan;
% pf_sum(5) = n_p_and_f/nsig_p_chan;

pf_sum(find(isnan(pf_sum) == 1)) = 0;
anova1(pf_sum); % This is nice for plotting the results

h(5) = gcf; % Get the handle for the whisker plot
set(gca, 'TickDir', 'out', 'box', 'off', 'FontName', 'Times New Roman');
axis square;
ylabel('Fraction of channels');

fname = sprintf('%s_Spec_stats_summary_%s - - STATS - POWER FV Fraction changes',pt_name, upper(bl_type));
set(h(end), 'name', fname);
handles = add_fig_h(handles, h(end), fname);


pf_sum_columns = {'Onset', 'P', 'FV', 'P|FV', 'FV|P'};
set(gca, 'XTick', 1:5 );
set(gca, 'XTickLabel', pf_sum_columns);

% Can't assume that these values are normally dsitributed since the ratios
% range from 0 1 - ergo not normal, so do ranksum between the number of
% channels with onset, and various combinations of the 5 columns:

% Column    1 - fraction (of total channels) with onsets
% Column    2 - fraction (of total channels) with increased power
% Column    3 - fraction (of total channels) with increased FV
% Column    4 - given sig FV, faction with increased P
% Column    5 - given sig P, fraction with increased FV

display(' ');
display('--- Summary of channel number statistics, see whisker plots also ---');
display(sprintf('Onsets %4.2f (%4.2f) vs. Power %4.2f (%4.2f), p = %6.2e', median(pf_sum(:,1)), iqr(pf_sum(:,1)), ...
    median(pf_sum(:,2)), iqr(pf_sum(:,2)), ranksum(pf_sum(:,1), pf_sum(:,2))));

display(sprintf('Onsets %4.2f (%4.2f) vs. FV %4.2f (%4.2f), p = %6.2e', median(pf_sum(:,1)), iqr(pf_sum(:,1)), ...
    median(pf_sum(:,3)), iqr(pf_sum(:,3)), ranksum(pf_sum(:,1), pf_sum(:,3))));

display(sprintf('P %4.2f (%4.2f) vs. FV %4.2f (%4.2f), p = %6.2e', median(pf_sum(:,2)), iqr(pf_sum(:,2)), ...
    median(pf_sum(:,3)), iqr(pf_sum(:,3)), ranksum(pf_sum(:,2), pf_sum(:,3))));

% Check which columns are significantly different from median of zero using
% (signtest)
display(' ');
display('--- Test to see which values are significantly different from median of zero');
for i=1:length(pf_sum_columns)
    vals = pf_sum(:,i);
    display(sprintf('%5s %6.2f (%6.2f), p = %6.2e', pf_sum_columns{i}, median(vals), iqr(vals), signtest(vals)));
end
display(' ');
display('--- Complete pf_sum table');
pf_sum





%% Correlation statistics between power and FV values at the frequencies specified in cfg.freqs

pfcorr = [];
for i=1:numel(R)
    [nfreq,ncond,~,nsz(i)] = size(R(i).pfcorr);
    pfcorr =  cat(3,pfcorr, reshape(R(i).pfcorr,nfreq,ncond,nchan(i)*nsz(i)));
end

% Compute the p-values on the raw correlation scores
for i=1:nfreq
    pfcorr_p(i,1) = pval(squeeze(pfcorr(i,1,:)),[]);
    pfcorr_p(i,2) = pval(squeeze(pfcorr(i,2,:)),[]);
    pfcorr_p(i,3) = pval(squeeze(pfcorr(i,1,:)),squeeze(pfcorr(i,2,:)));
    
end

% Normalize to the largest average value for plotting - this increases the
% range of values but does not affect their relationship
pfcorr_norm = nanmedian(pfcorr,3);
%pfcorr_norm = pfcorr_norm/(max(max(abs(pfcorr_norm))));

h(6) = figure; clf;
fname = sprintf('%s_Spec_stats_summary_%s - PFCORR',pt_name, upper(bl_type));
set(h(end), 'name', fname);
handles = add_fig_h(handles, h(end), fname);
cmap = flipud(cbrewer('div', 'RdYlBu', 10));
colormap(cmap);

subplot(2,1,1);
plot_pf(pfcorr_norm, a_cfg.freqs, 1);
plot_sig(pfcorr_p(:,1), a_cfg.stats.ph_tf_alpha, 1, nfreq,1);
plot_sig(pfcorr_p(:,2), a_cfg.stats.ph_tf_alpha, 2, nfreq,1);
colorbar;
title('Compared top median of zero');


subplot(2,1,2);
plot_pf(pfcorr_norm(:,2) - pfcorr_norm(:,2), a_cfg.freqs, 1);
plot_sig(pfcorr_p(:,3), a_cfg.stats.ph_tf_alpha, 1, nfreq,1);
colormap(cmap);
colorbar;
title(sprintf('%s vs. onset', bl_type));

display('--- PFCORR p-value matrix');
pfcorr_p


% Save all the figures
if save_figs
    display('Saving figures...');
    for i=1:numel(handles)
        save_figure(handles(i).h, FIGURE_DIR, handles(i).name,1);
    end
end

R_summary = struct_from_list('pfcorr', pfcorr, 'pfcorr_p', pfcorr_p, 'pf_sum',pf_sum);


function [] = plot_nsig_freqs(pt_names, yval, f_ind, f, cm)
bar(yval) % plot increases
set(gca,'TickDir', 'out');
set(gca, 'XTickLabel', pt_names);

% [f, f_ind,~] = intersect(a_cfg.stats.ph_tf_freqs, a_cfg.freqs);
% f(end+1) = a_cfg.stats.ph_tf_freqs(end);
% f_ind(end+1) = length(a_cfg.stats.ph_tf_freqs);
colormap(cm)
hcb = colorbar('YTick', f_ind, 'YTickLabel', num2str(f'));
set(hcb,'YTickMode','manual')
set(gca, 'box', 'off');
set(gca, 'FontName', 'Times New Roman');
ylabel('Fraction of channels');


function [] = plot_nsig_averages(m1, v1, p1, m2, v2, p2, x)

boundedline(x, m1, v1, 'b', x, m2, v2, 'g');
set(gca, 'TickDir', 'out', 'box', 'off', 'FontName', 'Times New Roman');
axis([x(1) x(end) -0.2 0.5]);
hold on;
for i=1:length(x)
    if p1(i)
        plot(x(i), m1(i), '.r', 'LineStyle', 'none');
    end
    if p2(i)
        plot(x(i), m2(i), '.r', 'LineStyle', 'none');
    end
    
end
hold off;
axis square;
xlabel('Hz');
ylabel('Fraction of channels');
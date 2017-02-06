function [] = Szprec_ph_tf_stats(sz_list, bl_type, recompute, save_figs)

% Function summarizes power and precursor changes for each channel, and as
% well computes the average correlation between power and precursor values.
% Requires the output of Szprec_ph_tf.

global FIGURE_DIR;

a_cfg = cfg_default();

if nargin < 2; bl_type = 'pre'; end;
if nargin < 3; recompute = 0; end
if nargin < 4; save_figs = 0; end;

% Set the subdir for the correct BaseLine (bl) period.
switch bl_type
    case 'pre'
        subdir = 'Ph_stats_pre';
    case 'start'
        subdir = 'Ph_stats_start';
end
a_cfg.stats.ph_tf_onset_seg = bl_type;
pt_name = strtok(sz_list{1}, '_');
handles = [];

% Setup the directory and file names
pdir = fullfile(make_data_path(pt_name,  'processed_dir'), subdir);
% Create the TF directory if it does not exist
if ~exist(pdir, 'dir')
    mkdir(pdir);
end

pfstats_file = fullfile(pdir, [pt_name '_PFSTATS.mat']);
infile = fullfile(pdir, [pt_name '_PH_TF.mat']);

if recompute
    display('Re-computing TF spectra...')
    S = Szprec_ph_tf(sz_list, pt_name, a_cfg);
    [spec_means, pfcorr, freqs] = compute_tf(S, a_cfg);
    save_pfstats = 1;
else
    if ~exist(pfstats_file, 'file')
    % See if the analysis already exists

        if exist(infile, 'file')
            tic
            load(infile)
            toc
        else
            display('Computing TF spectra...')
            S = Szprec_ph_tf(sz_list, pt_name, a_cfg);
        end
        [spec_means, pfcorr, freqs] = compute_tf(S, a_cfg);
        save_pfstats = 1;
    else
        display('Loading PF STATS file...')
        load(pfstats_file);
        save_pfstats = 0;
    end
end

[ch, ~] = get_channels_with_text(pt_name, [], 'bipolar');

% Channel stats of significant power and F changes
[~,h] = spec_stats(spec_means, a_cfg, 1);
fname = sprintf('%s_Spec_stats - POWER',pt_name);
set(h(1), 'name', fname);
handles = add_fig_h(handles, h(1), fname);

fname = sprintf('%s_Spec_stats - FV',pt_name);
set(h(2), 'name', fname);
handles = add_fig_h(handles, h(2), fname);


% Plot all the figures
h = plot_avg_ch_spec(spec_means,a_cfg, ch);
fname = sprintf('%s_F_spectrum_all_seizures',pt_name);
set(h(1), 'name', fname);
handles = add_fig_h(handles, h(1), fname);

fname = sprintf('%s_P_spectrum_all_seizures',pt_name);
set(h(2), 'name', fname);
handles = add_fig_h(handles, h(2), fname);

hcorr = plot_corr_p_to_f_tf(pfcorr,freqs,a_cfg,ch);
for i=1:(numel(hcorr)-1)
    fname = sprintf('%s_Power_prec_corr_%s', pt_name, sz_list{i});
    set(hcorr(i), 'Name', fname);
    handles = add_fig_h(handles, hcorr(i), fname);
end

fname = sprintf('%s_Power_prec_corr_ALL SEIZURES', pt_name);
set(hcorr(end), 'Name', fname);
handles = add_fig_h(handles, hcorr(end), fname);


% Save all the figures
if save_figs
    display('Saving figures...');
    for i=1:numel(handles)
        save_figure(handles(i).h, FIGURE_DIR, handles(i).name,1);
    end
end

%save the analyses
if save_pfstats
    display('Saving PFSTATS file...')
    save(pfstats_file, 'pfcorr', 'spec_means', 'a_cfg', 'ch', 'freqs', 'pt_name');
end

function [spec_means, pfcorr, freqs] = compute_tf(S, a_cfg)
% Compute the spectral averages and the power to F(precursor) correlations
display('Computing average spectra...');
spec_means = avg_ch_spec(S, a_cfg);

display('Computing time resolved power-precursor correlations...');
[pfcorr, freqs] = corr_p_to_f_tf(S, a_cfg);

% % Cluster analysis
% % Need the average PH results
% ph_file = fullfile(DATA_PATH, 'Szprec', pt_name, 'Processed\Adaptive deriv', [pt_name '_PH_Summary_early.mat']);
% if exist(ph_file, 'file')
%     load(ph_file);
%     ch_cluster(pfcorr, R, ch);
% else
%     display(ph_file);
%     display('Unable to load PH file, aborting clustering procedure');
% end




% % plot individual spectra for each cnannel and seizure
% for i=1:numel(S)
%     if ~isempty(S)
%         h = plot_S(S{i}, a_cfg, channels);
%         set(h(1), 'name', sprintf('%s - F_spectrum',sz_list{sz_ind}{i}));
%         set(h(2), 'name', sprintf('%s - P_spectrum',sz_list{sz_ind}{i}));
%     end
% end

% summarize(spec_means, a_cfg);
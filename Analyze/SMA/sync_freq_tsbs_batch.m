function [] = sync_freq_tsbs_batch(EEG)

P = pairs_nourse();

ch_pairs = pairs_all([4:7 13 8 6]);
npairs = length(ch_pairs);

% ANALYSIS Params that need to be set externally
ap = sync_params();
ap.condlist = {'aloud','quiet','rest_eo'};
ap.atype = 'ic';
ap.ptname = 'nourse';
ap.usewt = 1;
ap.freqs = [20:2:50 60:10:500];
ap.yaxis = [0 0.5];
ap.nsurr = 1000; % Number of surrogates to run
%ap.sync_freq_surr = 'rand_pairs';
ap.sync_freq_surr = 'time_shift';
ap.nsurrch = 12;

for i=1:npairs
    sync_freq_tsbs(EEG, ch_pairs(:,i), ap, 1);
end

% Do another set of pairs
ch_pairs = pairs_2rois([P.BA P.FMC],48);

for i=1:npairs
    sync_freq_tsbs(EEG, ch_pairs(:,i), ap, 1);
end



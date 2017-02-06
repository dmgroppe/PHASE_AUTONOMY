function [] = sync_freq_tsbs_batch(EEG)

ch_pairs = pairs_2rois([7 8 15 16], [59 60 61]);
npairs = length(ch_pairs);

% ANALYSIS Params that need to be set externally
ap = sync_params();
ap.condlist = {'aloud', 'quiet', 'rest_eo'};
ap.atype = 'pc';
ap.ptname = 'vant';
ap.usewt = 1;
ap.freqs = 50:10:500;
ap.yaxis = [];
ap.nsurr = 200; % Number of surrogates to run

for i=1:npairs
    sync_freq_tsbs(EEG, ch_pairs(:,i), ap, 1);
end

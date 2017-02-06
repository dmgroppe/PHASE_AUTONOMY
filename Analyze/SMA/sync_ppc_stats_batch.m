function [] = sync_ppc_stats_batch(EEG, pairs, ptname)

sync_ppc_trials_batch(EEG, pairs, {'aloud', 'quiet', 'rest_eo'}, ptname);

if min(size(pairs)) == 1
    sync_ppc_bs_batch(EEG, pairs, ptname)
else
    for i=1:size(pairs,2)
        sync_ppc_bs_batch(EEG, pairs(:,i), ptname)
    end
end
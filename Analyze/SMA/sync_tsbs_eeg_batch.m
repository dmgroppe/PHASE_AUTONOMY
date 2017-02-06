function [] = sync_tsbs_eeg_batch(EEGs)

for i=1:numel(EEGs)
    sync_freq_tsbs(EEGs{i}, [8 16], sync_params(), 1);
end
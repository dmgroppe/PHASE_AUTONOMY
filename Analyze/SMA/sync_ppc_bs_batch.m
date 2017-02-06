function [] = sync_ppc_bs_batch(EEG, pair, ptname)

sync_ppc_bs(EEG, pair, 'aloud', ptname);
sync_ppc_bs(EEG, pair, 'quiet', ptname);
sync_ppc_bs(EEG, pair, 'rest_eo', ptname);


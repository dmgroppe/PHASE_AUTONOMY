function [] = sync_ppc_batch(EEG, pairs)

ap = sync_params();
condlist = ap.condlist;
ptname = ap.ptname;

parfor i=1:length(pairs)
    for j=1:numel(condlist)
        sync_phase_power_corr_grid(EEG, pairs(:,i), condlist{j}, ptname, 1,1,0);
    end
end
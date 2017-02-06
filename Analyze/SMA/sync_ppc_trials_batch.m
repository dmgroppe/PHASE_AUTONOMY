function[] = sync_ppc_trials_batch(EEG, pairs, condlist, ptname)

npairs = size(pairs,1);

for i=1:numel(condlist)
    cond = condlist{i};
    for j=1:npairs
        if min(size(pairs)) == 1
            sync_ppc_trials(EEG, pairs, cond, ptname, 1, 1);
        else
            sync_ppc_trials(EEG, pairs(:,j), cond, ptname, 1, 1);
        end
    end
end

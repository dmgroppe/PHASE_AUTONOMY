function [] = batch_sync_freq_compare(EEG, pairs)

ap = sync_params();
%condlist{1} = {'aloud', 'quiet', 'rest_eo'};
condlist{1} = {'aloud', 'rest_eo'};
condlist{2} = {'quiet', 'rest_eo'};

atypes = {'ic'};

for i=1:numel(condlist)
    ap.condlist = condlist{i};
    for j=1:numel(atypes)
        ap.atype = atypes{j};
        sync_freq_compare(EEG, pairs, ap);
    end
end




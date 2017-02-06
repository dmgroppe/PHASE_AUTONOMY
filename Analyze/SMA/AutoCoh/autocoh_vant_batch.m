function [] = autocoh_vant_batch()
EEG = load_vant();

channels = [7 8 15 16 59 60 61];
conds = {'aloud', 'quiet', 'rest_eo'};
eDir = 'E:\Projects\Data\Vant\Figures\Super\AutoCoh\Vant-CGT\';

for i=1:length(channels)
    for j=1:numel(conds)
        [EEGCGT, R] = sync_autocoh(EEG, channels(i), conds{j}, 'vant', 60:200, false);
        fname = sprintf('EEGCGT_VANT_%s_%d.mat', conds{j},channels(i));
        save([eDir fname], 'EEGCGT', 'R');
    end
end
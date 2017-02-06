function [] = batch_SMA_ms(EEG)

chlist = [16, 49, 60, 61];

for i=1:length(chlist)
    fprintf('Working on CH %d: %d of %d', chlist(i), i, length(chlist));
    tic
    ms_SMA(EEG,'aloud',60,chlist(i),500,1);
    toc
end

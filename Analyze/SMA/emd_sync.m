function [sync sync_sum] = emd_sync(EMD, EEG, channels, max_emd, atype, chpair, dosave)

if nargin < 5; dosave = false; end;

ap = sync_params();

[~, nchannels] = size(EMD);
T = (1:length(EMD{1}))/EEG.srate;

if nchannels ~= length(channels)
    error('Not enought channels');
end

fh = sync_fh(atype);
h = figure(1); 

ts1 = EMD{find(chpair(1) == channels)};
ts2 = EMD{find(chpair(2) == channels)};



fname = 'SYNC_EMD';
set(h, 'Name', fname);
nemd = min([size(EMD{find(chpair(1) == channels)}, 1) size(EMD{find(chpair(2) == channels)}, 1)]);

if max_emd < nemd
    nplot = max_emd;
else
    nplot = nemd;
end

for j=1:nplot
    emd_sum1 = sum(ts1(1:j,:), 1);
    emd_sum2 = sum(ts2(1:j,:), 1);
    
    sync_sum(j) = fh(hilbert(emd_sum1), hilbert(emd_sum2));
    sync(j) = fh(hilbert(ts1(j,:)), hilbert(ts2(j,:)));
end

bar([sync_sum' sync']);

if dosave
    save_figure(h,get_export_path_SMA(), fname);
end

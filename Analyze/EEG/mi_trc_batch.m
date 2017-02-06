function [] = mi_trc_batch(EEG,chtoincl, chtoexcl,window,lf,hf,poverlap, ftext, dosave)

if nargin < 9; dosave = 1; end;

eDir = 'D:\Projects\Data\MI_PDPC\';

wnumber = 5;
nbins = 12;
srate = EEG.srate;

if ~isempty(chtoincl)
    channels = chtoincl;
else
    channels = 1:size(EEG.data,1);
    channels(chtoexcl) = [];
end

nchan = length(channels);

for i=1:nchan
    [mi, T] = mi_tr_continuous(EEG.data(channels(i),:), window, lf, hf, poverlap, srate, wnumber, nbins, true);
    fname = sprintf('%s_CH%d',upper(ftext), channels(i));
    set(gcf, 'Name', fname);
    if dosave
        save([eDir fname '_TR_MI' '.mat'], 'mi', 'T', 'lf', 'hf','poverlap','nbins','wnumber','channels', 'srate');
        save_figure(gcf,eDir,fname, false);
    end
end

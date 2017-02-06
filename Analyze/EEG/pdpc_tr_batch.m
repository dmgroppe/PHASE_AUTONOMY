function [] = pdpc_tr_batch(EEG, chtoexcl, freqs, ftext)

eDir = 'D:\Projects\Data\MI_PDPC\';

wnumber = 5;
window = 5000;
poverlap = 90;
nbins = 12;
srate = EEG.srate;


display('Computing wavelet transform for each channel...this will take a while and alot of memory!!!')
[wt, channels] = wt_EEG(EEG, chtoexcl, freqs, wnumber);

for i=1:length(channels)
    for j=i+1:length(channels)
        [pdpc, T] = pdpc_tr(wt(:,:,i), wt(:,:,j), window, freqs, poverlap, nbins, srate, wnumber, true);
        fname = sprintf('%s_CH%d_CH%d',upper(ftext), channels(i), channels(j));
        set(gcf,'Name', ['Time resolved PDPC ' fname]);
        save_figure(gcf,eDir, fname,false);
        save([eDir fname '_TR_PDPC' '.mat'], 'pdpc', 'T', 'freqs','poverlap','nbins','wnumber','channels', 'srate');
    end
end



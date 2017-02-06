function [] = plot_tsbs_summary()

Dir = 'D:\Projects\Data\Vant\Figures\Super\TSBS\';
atype = 'pc';
ptname = 'vant';
surr_type_name = 'TS';

ch_pairs = pairs_2rois([7 8 15 16], [59 60 61]);
npairs =size(ch_pairs,2);

for i=1:npairs
    fname = sprintf('Sync_freq_dep %s %sBS %s %s CH %d-%d.mat', upper(atype),...
        surr_type_name, ptname, atype, ch_pairs(1,i), ch_pairs(2,i));
    if ~exist([Dir fname], 'file');
        display([Dir fname]);
        display('File does not exist...exiting.')
        return;
    end
    load([Dir fname]);
    ms_all(:,:,i) = ms;
    sig_inc_all(:,:,i) = sig_inc;
    sig_dec_all(:,:,i) = sig_dec;
    ap_all{i} = ap;
end
freqs = ap_all{1}.freqs;

cum_sig = sum(sig_inc_all, 3);
figure(1);

plot(freqs, cum_sig/npairs);
axis([freqs(1), freqs(end) 0 1])


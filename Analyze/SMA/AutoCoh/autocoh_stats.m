function [] = autocoh_stats(ptname, channel, cond, doplot)
eDir = 'E:\Projects\Data\Vant\Figures\Super\AutoCoh\Vant-CGT\';
fname = sprintf('EEGCGT_%s_%s_%d.mat', upper(ptname), cond,channel);

if exist([eDir fname], 'file')
    load([eDir fname]);
else
    display('Transform file not found');
end

ap = sync_params();
freq = EEGCGT.freqs;

h = figure(1);
fname = sprintf('ACOH Stats %s %s CH%d', upper(ptname), upper(cond), channel);
set(h, 'Name', fname);
plot_autocoh(ap, R, EEGCGT.srate, EEGCGT.freqs);
drawnow;

[R_burst ~] = sync_autocoh_surr(EEGCGT, R, 'burst');
[R_noise ~] = sync_autocoh_surr(EEGCGT, R, 'noise');

h = figure(2);
fname = sprintf('ACOH Stats %s %s CH%d - BURST MODEL', upper(ptname), upper(cond), channel);
set(h, 'Name', fname);
plot_autocoh(ap, R_burst{1}, EEGCGT.srate, EEGCGT.freqs);

h = figure(3);
fname = sprintf('ACOH Stats %s %s CH%d - NOISE MODEL', upper(ptname), upper(cond), channel);
set(h, 'Name', fname);
plot_autocoh(ap, R_noise{1}, EEGCGT.srate, EEGCGT.freqs);

mdist = sum(R.prob_dist,2);
burst_mdist = sum(R_burst{1}.prob_dist,2);
noise_mdist = sum(R_noise{1}.prob_dist,2);

h = figure(4);
plot(freq,mdist,freq, burst_mdist, freq, noise_mdist);
 



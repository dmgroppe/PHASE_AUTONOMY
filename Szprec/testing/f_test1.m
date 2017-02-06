function [] = f_test1(d, ch1, ch2, Sf, freqs)


d = remove_nans(d);
wt1 = twt(d(:,ch1), Sf, linear_scale(freqs, Sf), 5);
wt2 = twt(d(:,ch2), Sf, linear_scale(freqs, Sf), 5);

cfg.ncycles = 10;
cfg.win = 1;
cfg.use_fband = false;
cfg.freqs = freqs;
cfg.diff_adaptive = 1;
cfg.diff_adaptive_rads = pi;

F = precursor(wt1, wt2, Sf, cfg);

f = mean(F,[],1);
T = (0:(length(d)-1))/Sf;

nplots = 3;
figure;clf
ax(1) = subplot(nplots,1,1);
plot(T,d(:,[ch1 ch2]));
axis([0 T(end) ylim]);

ax(2) = subplot(nplots,1,2);
imagesc(T,freqs,F);
%axis([0 T(end)]);

ax(2) = subplot(nplots,1,3);
f = max(F,[],1);
plot(T,f);
axis([0 T(end) ylim]);
linkaxes(ax, 'x');


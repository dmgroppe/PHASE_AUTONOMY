function [] = Sprec_spectrogram(d, srate, freqs, chan)

[npoints nchan] = size(d);
d = remove_nans(d);
T = (0:(npoints-1))/srate; % Time in seconds

wt = abs(twt(d(:,chan), srate, linear_scale(freqs, srate), 5));
z = wt./repmat(mean(wt,2), 1, length(wt));

ax(1) = subplot(2,1,1);
surf(T,freqs,z);
axis([T(1), T(end) freqs(1) freqs(end) min(min(z)), max(max(z))]);
view(0,90);
shading interp;
caxis([0 3]);
set(gca, 'YScale', 'log');

ax(2) = subplot(2,1,2);
plot(T, d(:,chan));
axis([T(1) T(end) ylim]);


linkaxes(ax, 'x');








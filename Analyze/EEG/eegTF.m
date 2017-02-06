function [] = eegTF(EEG, channels, freqs, pskip)

if nargin < 4; pskip = 10; end

[~, npoints] = size(EEG.data);
T = (0:(npoints-1))/EEG.srate;

[r c] = rc_plot(length(channels));
count = 0;
figure(1);clf;
for i=1:length(channels)
    count = count + 1;
    ch = channels(i);
    ax(count) = subplot(r,c,count);
    wt = twt(EEG.data(ch,:),EEG.srate,linear_scale(freqs,EEG.srate),5);
    pcolor(T(1:pskip:end),freqs,zscore(abs(wt(:,1:pskip:end))));
    shading interp;
    set(gca, 'YTick', [1 10 100 max(freqs)]);
    set(gca, 'YScale', 'log');
    title(EEG.label(ch), 'FontSize', 5);
    set(gca, 'FontSize', 5);
    drawnow;
end

linkaxes(ax, 'xy');
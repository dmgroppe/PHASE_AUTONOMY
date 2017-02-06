function [pdiff] = phase_sync(EEG, ch1, ch2, lowcut, highcut, sr, rp)

if (nargin < 7); rp = 0; end;

seg1 = eegfilt(double(EEG.data(ch1,sr(1):sr(2))), EEG.srate, lowcut, highcut);
seg2 = eegfilt(double(EEG.data(ch2,sr(1):sr(2))), EEG.srate, lowcut, highcut);

if (rp)
    seg1 = scramble_phase(seg1);
    seg2 = scramble_phase(seg2);
end

pdiff = phase_diff(unwrap(angle(hilbert(seg1))) - unwrap(angle(hilbert(seg2))));
p1 = abs(hilbert(seg1));
p2 = abs(hilbert(seg2));

figure(1);

ax(1) = subplot(3,1,1);
x = (1:length(seg1))/EEG.srate*1000;
plot(x,seg1,x,p1);
xlabel('Time ms');
ylabel('Amplitude');

ax(2) = subplot(3,1,2);
plot(x,seg2,x,p2);
xlabel('Time ms');
ylabel('Amplitude');

ax(3) = subplot(3,1,3);
plot(x,pdiff);
xlabel('Time ms');
ylabel('Phase difference');

linkaxes(ax, 'xy');

h = figure(2);
set(h, 'Name', sprintf('Ch%d-Ch%d', ch1, ch2));
hist(pdiff,180);
xlabel('Phase difference');
ylabel('Count');









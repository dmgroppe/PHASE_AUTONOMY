function [] = plot_autocoh(ap, R, srate, freqs)

% Convert some of the lengths to milliseconds
hlengths_ms = R.hlengths/srate*1000;
avglengths_ms = R.avglengths/srate*1000;

% Plot the number various burst parameters
subplot(6,1,1);
plot(freqs, R.counts);
axis([freqs(1) freqs(end) min(min(R.counts)) max(max(R.counts))]);
ylabel('Counts', ap.pl.textprop, ap.pl.textpropval);
xlabel('Frequency');
title('Burst count');
set(gca, ap.pl.textprop, ap.pl.textpropval);
set(gca, 'TickDir', 'out');

subplot(6,1,2);
plot(freqs, R.avgamps);
axis([freqs(1) freqs(end) min(min(R.avgamps)) max(max(R.avgamps))]);
ylabel('Mean norm amp', ap.pl.textprop, ap.pl.textpropval);
xlabel('Frequency', ap.pl.textprop, ap.pl.textpropval);
title('Burst Amplitude', ap.pl.textprop, ap.pl.textpropval);
set(gca, ap.pl.textprop, ap.pl.textpropval);
set(gca, 'TickDir', 'out');

subplot(6,1,3);
plot(freqs, avglengths_ms);
axis([freqs(1) freqs(end) min(min(avglengths_ms)) max(max(avglengths_ms))]);
ylabel('Avg length (ms)', ap.pl.textprop, ap.pl.textpropval);
xlabel('Frequency', ap.pl.textprop, ap.pl.textpropval);
title('Burst Length', ap.pl.textprop, ap.pl.textpropval);
set(gca, ap.pl.textprop, ap.pl.textpropval);
set(gca, 'TickDir', 'out');

subplot(6,1,4);
plot(freqs, R.ac_count);
axis([freqs(1) freqs(end) min(R.ac_count) max(R.ac_count)]);
xlabel('Frequency (Hz)', ap.pl.textprop, ap.pl.textpropval);
ylabel('# autocoh bursts', ap.pl.textprop, ap.pl.textpropval);
title('Autocoherency', ap.pl.textprop, ap.pl.textpropval);
set(gca, ap.pl.textprop, ap.pl.textpropval);
set(gca, 'TickDir', 'out');

subplot(6,1,5);
p_autocoh = R.ac_count./R.counts;
plot(freqs, p_autocoh);
%axis([freqs(1) freqs(end) min(p_autocoh) max(p_autocoh)]);
axis([freqs(1) freqs(end) 0 1.5]);
xlabel('Frequency (Hz)', ap.pl.textprop, ap.pl.textpropval);
ylabel('p autocoh bursts', ap.pl.textprop, ap.pl.textpropval);
title('Probability of autocoherency', ap.pl.textprop, ap.pl.textpropval);
set(gca, ap.pl.textprop, ap.pl.textpropval);
set(gca, 'TickDir', 'out');

subplot(6,1,6);
surf(hlengths_ms,freqs, R.prob_dist);
axis([hlengths_ms(1) hlengths_ms(end) freqs(1) freqs(end) 0 1]);
view(0,90);
if ~isempty(ap.autocoh.prob_caxis)
    caxis(ap.autocoh.prob_caxis);
else
    caxis([0 max(max(R.prob_dist))]);
end
shading flat;
xlabel('Burst length (ms)', ap.pl.textprop, ap.pl.textpropval);
ylabel('Frequency (Hz)', ap.pl.textprop, ap.pl.textpropval);
title('Joint probability distribution', ap.pl.textprop, ap.pl.textpropval);
set(gca, ap.pl.textprop, ap.pl.textpropval);
set(gca, 'TickDir', 'out');
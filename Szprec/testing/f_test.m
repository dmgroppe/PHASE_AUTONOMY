function [] = f_test(d, ch1, ch2, Sf, freq)


d = remove_nans(d);
wt1 = twt(d(:,ch1), Sf, linear_scale(freq, Sf), 5);
wt2 = twt(d(:,ch2), Sf, linear_scale(freq, Sf), 5);

h=figure(29);
plot_results(wt1, wt2, ch1, ch2, d, Sf, freq);
set(h, 'Name', 'Wavelet Transform');


h=figure(30);
set(h, 'Name', 'Hilbert');
bp_filter = window_FIR(60,100,Sf,1000);
wt1 = hilbert(filtfilt(bp_filter.Numerator, 1, d(:,ch1)));
wt2 = hilbert(filtfilt(bp_filter.Numerator, 1, d(:,ch2)));
plot_results(wt1, wt2, ch1, ch2, d, Sf, freq);

function [] = plot_results(wt1, wt2, ch1, ch2, d, Sf, freq)

p1 = angle(wt1);
p2 = angle(wt2);

nplot = 6;

T = (0:(length(d)-1))/Sf;
ax(1) = subplot(5,1,1);
plot(T,d(:,[ch1, ch2]));

ax(2) = subplot(nplot,1,2);
plot(T,p1, T, p2);
title('phase');

ax(3) = subplot(nplot,1,3);
plot(T,abs(wt1), T, abs(wt2));
title('power');

ax(4) = subplot(nplot,1,4);
pdif2 = phase_diff(angle((wt1.*conj(wt2))./(abs(wt1).*abs(wt2))));
%plot(T,phase_diff(p1-p2), T,pdif2+1);
plot(T,pdif2);
title('Phase difference');

ax(5) = subplot(nplot,1,5);
pdif = unwrap(angle((wt1.*conj(wt2))./(abs(wt1).*abs(wt2))));
win = fix( 10/freq*Sf);
pdif = pdif(:);
t = padarray(pdif,[fix(win/2)+1 0],'replicate');
f = average(abs(diff(t)), win);
f = f(1:length(d));
plot(T,smooth(f,Sf));
title('Precursor');

ax(6) = subplot(nplot,1,6);
pdif = unwrap(angle(wt1)) - unwrap(angle(wt2));
%win = fix( 10/freq*Sf);
%pdif = pdif(:);
f = var_windowed(pdif,win);
plot(T,smooth(f,Sf));
title('Variance of phase difference');

linkaxes(ax, 'x');



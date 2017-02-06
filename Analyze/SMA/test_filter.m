function [] = test_filter(EEG, ch, frange)

[tstart tend] = get_trange('aloud', 60);
tstart = tstart/1000*EEG.srate;
tend = tend/1000*EEG.srate;

x = EEG.data(ch, tstart:tend);
window = EEG.srate * 2;

 [prefilt,~,~] = powerspec(x,window, EEG.srate);
%[b,a]  = cheby2_bp(EEG.srate, frange(1), frange(2));
%d = bpfilter(frange(1), frange(2), EEG.srate);
d = window_FIR(frange(1), frange(2), EEG.srate);
%d = bstop(179, 181, EEG.srate);

%[postfilt,w,~] = powerspec(filtfilt(b,a,x),window, EEG.srate);
filtered = filtfilt(d.Numerator,1,x);
[postfilt,w,~] = powerspec(filtered,window, EEG.srate);

figure(1);
subplot(2,1,1);
semilogy(w,prefilt, w, postfilt);
subplot(2,1,2);
plot(filtered);
legend('Pre', 'Post');




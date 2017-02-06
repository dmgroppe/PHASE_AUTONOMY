function [] = sync_meanph_compare(EEG, ch, highf, lowf, cond, ptname)

ap = sync_params();

[tstart tend] = get_trange(cond, ap.length, ptname);
subr = get_subregion(EEG, tstart, tend);
subr = subr(ch,:);

d = window_FIR(highf(1), highf(2), EEG.srate);
high1 = hilbert(filtfilt(d.Numerator,1,subr(1,:)));
high2 = hilbert(filtfilt(d.Numerator,1,subr(2,:)));

d = window_FIR(lowf(1), lowf(2), EEG.srate);
low1 = hilbert(filtfilt(d.Numerator,1,abs(high1)));
low2 = hilbert(filtfilt(d.Numerator,1,abs(high2)));

fratio = mean(highf)/mean(lowf);

dphihigh = phase_diff(angle(high1)-angle(high2));
dphilow = phase_diff(angle(low1) - angle(low2));

figure(1);
subplot(3,1,1);
rose(dphihigh);
title('High')

subplot(3,1,2);
rose(dphilow);
title('Low envelope');

fprintf('\nMean time for high = %6.2f (ms)', circ_mean(dphihigh)/(2*pi)/mean(highf)*1000);
fprintf('\n Deviation from non-uniformity, p =%e\n', circ_rtest(dphihigh));
fprintf('\n IS mean phase = 0, h =%d\n (p<.0001)', circ_mtest(dphihigh, 0));
fprintf('\nMean time for low = %6.2f (ms)', circ_mean(dphilow)/(2*pi)/mean(lowf)*1000);
fprintf('\n Deviation from non-uniformity, p =%e', circ_rtest(dphilow));
fprintf('\n IS mean phase = 0, h =%d\n (p<.0001)', circ_mtest(dphilow, 0));

d = window_FIR(lowf(1), lowf(2), EEG.srate);
low1 = hilbert(filtfilt(d.Numerator,1,subr(1,:)));
low2 = hilbert(filtfilt(d.Numerator,1,subr(2,:)));

subplot(3,1,3);
dphi = phase_diff(angle(low1) - angle(low2));
rose(dphi);
title('Low LFP');
fprintf('\nMean time for low LFP= %6.2f (ms)\n', circ_mean(dphi)/(2*pi)/mean(lowf)*1000);
fprintf('\n Deviation from non-uniformity, p =%e\n', circ_rtest(dphi));
fprintf('\n IS mean phase = 0, h =%d\n (p<.0001)', circ_mtest(dphi, 0));

%circ_kuipertest(dphihigh, dphilow);





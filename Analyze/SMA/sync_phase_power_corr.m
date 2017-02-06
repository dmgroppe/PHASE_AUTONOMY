function [bins, rho, p] = sync_phase_power_corr(EEG, ch, frange, cond, ptname)

ap = sync_params();

[tstart tend] = get_trange(cond, ap.length, ptname);
subr = get_subregion(EEG, tstart, tend);

d = window_FIR(frange(1), frange(2), EEG.srate);
h1 = hilbert(filtfilt(d.Numerator,1,subr(ch(1),:)));
h2 = hilbert(filtfilt(d.Numerator,1,subr(ch(2),:)));

%dphi = (angle(h1) - angle(h2))/2;

[meana1, meana2, rho, p, bins] = sync_ppc(h1, h2, ap.ppc.nbins);

figure(1);
subplot(3,1,1);
bar(bins(1:end-1), meana1);
xlabel('Radians')
ylabel('Mean 1');

subplot(3,1,2);
bar(bins(1:end-1), meana2);
xlabel('Radians')
ylabel('Mean 2');

subplot(3,1,3);
bar(bins(1:end-1), rho);
xlabel('Radians')
ylabel('Spearman rho');
if ~isempty(ap.yaxis)
    axis([-pi, pi, ap.yaxis]);
end
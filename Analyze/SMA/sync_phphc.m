function []= sync_phphc(EEG, cond, ch, ptname)

ap = sync_params();

subr = data_retrieve(EEG, cond, ap.length, ptname);
high_x = subr(ch,:);

if ap.surr
    high_x = scramble_phase(high_x);
end

d = window_FIR(ap.nmpl.highf(1), ap.nmpl.highf(2), EEG.srate);
high_filt = filtfilt(d.Numerator, 1, high_x);
high_h = hilbert(high_filt);
high_ph = angle(high_h);
high_a = abs(high_h);

d = window_FIR(ap.nmpl.lowf(1), ap.nmpl.lowf(2), EEG.srate);
low_filt = filtfilt(d.Numerator, 1, high_a);
low_ph = angle(hilbert(low_filt));

nphase_bins = 360;
bins = -pi:2*pi/nphase_bins:pi;
counts = zeros(1,nphase_bins);

for i=1:length(ap.nmpl.m)
    pdiff = phase_diff(high_ph - phase_diff(ap.nmpl.m(i)*low_ph));
    for j=1:nphase_bins
        counts(j) = length(find(pdiff > bins(j) & pdiff < bins(j+1)));        
    end
    pl(i) = getp(counts, nphase_bins, 8, 45);
end



plot(ap.nmpl.m, pl);
shading flat;
view(0,90);





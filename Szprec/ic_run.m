npoints = 10000;
srate = 500;
osc_freq = 8;
n_fac = 5;
cfg.freqs = 4:15;
phase_shift = pi/4;


d1 = sin_wave(osc_freq,npoints,srate,0) + n_fac*rand(1,npoints);
d2 = sin_wave(osc_freq,npoints,srate,phase_shift) + n_fac*rand(1,npoints);


figure(1);clf;
T = (0:(npoints-1))/srate;
plot(T,d1, T,d2);

s = linear_scale(cfg.freqs,srate);
wt1 = twt(d1,srate,s,5);
wt2 = twt(d2,srate,s,5);

F = Szprec_imag_coherence(wt1, wt2, srate, cfg);
imagesc(T,cfg.freqs,F);
caxis([0 0.5]);

figure(2);
imagesc(T,cfg.freqs,abs(wt1));






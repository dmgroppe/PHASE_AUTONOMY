function [] = osc_detect()

frange = [4 8];
srate = 500;
forder = 1000;
npoints = 10000;
ncycles = 5;


n = rand(1,npoints);
n(5000:5999) = n(5000:5999) + sin_wave(mean(frange),1000, srate,0)*0.1;
plot(n);

h = window_FIR(frange(1), frange(2), srate, forder);
osc = filtfilt(h.Numerator,1, n);
osc_ph = angle(hilbert(osc));

figure(1);clf;
subplot(2,1,1);
[pks, loc] = findpeaks(osc_ph);
plot(osc_ph);
hold on;
plot(loc, osc_ph(loc), '.r', 'LineStyle', 'none');
hold off;

subplot(2,1,2);
p = 1/mean(frange)*srate;
plot(loc(1:end-1), 1./(diff(loc)-p));




% % construct basis oscillation
% swave = sin_wave(mean(frange), npoints,srate,0);
% sw_h = hilbert(swave);
% 
% % compute phase difference
% 
% cfg.ncycles = ncycles;
% cfg.use_fband = 1;
% cfg.fband = frange;
% 
% pc = Szprec_phase_coherence(osc_h', sw_h', srate, cfg);
% 
% 
% figure(1);clf;
% ax(1) = subplot(2,1,1);
% T = (0:(npoints-1))/srate;
% plot(T, n);
% ax(2) = subplot(2,1,2);
% plot(T,fisherz(pc));
% 
% linkaxes(ax, 'x');

figure(2);clf;
[ps, w, ~] = powerspec(n,srate,srate);
loglog(w,ps);





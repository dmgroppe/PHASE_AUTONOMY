function [] = phase_slip(freq, sr, npoints)

dt = 5;
mod_strength = 0.5;
freqs = 1:1:50;
T = (0:(npoints-1))/sr;
tol = 0.1;

% s = sin_wave(freq,npoints,sr);
% ph_mod = sin_wave(4,npoints,sr);
% 
% ts = sin(angle(hilbert(s))+ph_mod*mod_strength);
% ax(1) = subplot(2,1,1);
% plot(T,ts);
% 
% ax(2)=subplot(2,1,2);
% %gt = cgt(ts,dt,freqs,sr);
% gt = twt(ts,sr,linear_scale(freqs,sr), 10);
% surf(T,freqs,abs(gt));
% shading flat;
% view(0,90);
% 
% linkaxes(ax, 'x');

h = window_FIR(8,12,sr,1000);
x = filtfilt(h.Numerator, 1, rand(1,npoints));
phi = angle(hilbert(x));
[pks, loc] = findpeaks(phi);

good = find(abs(pks) >=(pi-tol));
gind = loc(good);
f = 1./(diff(gind)/sr);
plot(f);

% plot(T,phi);
% hold on;
% plot(T(loc), phi(loc), 'r.', 'LineStyle', 'none');
% hold off;






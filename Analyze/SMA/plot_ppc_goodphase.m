function [] = plot_ppc_goodphase(mean_phase, ap)
% Good phase plot

subplot(2,2,1);
label.x = 'Frequency (Hz)';
label.y = 'Phase (radians)';
label.title = 'Good phase';
plot_xy(ap.freqs, mean_phase, label, [-pi pi]);
plot_ranges(ap.extrema_range, [-pi pi], 'vert');


% Unwrapped good phase
subplot(2,2,2)
uangle = unwrap(mean_phase);
label.x = 'Frequency (Hz)';
label.y = 'Phase (radians)';
label.title = 'Unwrapped phase';
plot_xy(ap.freqs, uangle, label, []);
plot_ranges(ap.extrema_range, [min(uangle) max(uangle)], 'vert');


% Time delay at given good phase (not unwrapped)
subplot(2,2,3)
time_delay = mean_phase/(2*pi)./ap.freqs*1000;

label.x = 'Frequency (Hz)';
label.y = 'Time delay (ms)';
label.title = 'Time delay';
plot_xy(ap.freqs, time_delay, label, []);
plot_ranges(ap.extrema_range, [min(time_delay) max(time_delay)], 'vert');

% Time delay at given good phase (unwrapped)
subplot(2,2,4)
uangle = unwrap(mean_phase);
time_delay = uangle/(2*pi)./ap.freqs*1000;

label.x = 'Frequency (Hz)';
label.y = 'Time delay (ms)';
label.title = 'Time delay (unwrapped)';
plot_xy(ap.freqs, time_delay, label, []);
plot_ranges(ap.extrema_range, [min(time_delay) max(time_delay)], 'vert');
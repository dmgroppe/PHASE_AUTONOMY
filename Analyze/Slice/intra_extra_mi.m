function [] = intra_extra_mi(ap, ec_range, ic_range, tstart, tend)

[Dir] = file_get_path(ap);
S = abf_load(Dir, ap.fname, ap.srate, tstart, tend);
T = (0:(length(S.data)-1))/ap.srate; % Convert to ms
ic = ap.icchan;
ec = ap.ecchan;

if ap.notch
    xec = harm(S.data(ec,:),ap.notches,ap.srate, ap.bstop, ap.nharm);
    xic = harm(S.data(ic,:),ap.notches,ap.srate, ap.bstop, ap.nharm);
end

% ec_wt = twt(xec, ap.srate, linear_scale(ec_range, ap.srate), ap.wnumber);
% ic_wt = twt(xic, ap.srate, linear_scale(ic_range, ap.srate), ap.wnumber);

[ec_wt, freqs] = twt(xec, ap.srate, log_scale(ap.wt.ostart, ap.wt.noctaves, ap.wt.nvoices), ap.wnumber);
ic_wt = twt(xic, ap.srate, log_scale(ap.wt.ostart, ap.wt.noctaves, ap.wt.nvoices), ap.wnumber);


%lf_phase = angle(lf_wt);
%hf_env = abs(twt(S.data(ic,:), sr, linear_scale(hfrange, sr), ap.wnumber));

h = figure(1);
set(h,'Name', ap.fname);
ax(1) = subplot(2,1,1);
plot(T,filter_t(xec, [ec_range(1) ec_range(end)], ap.srate)*1000);
xlabel('Time (s)');
ylabel('uV');
title('Extracellular');


ax(2) = subplot(2,1,2);
plot(T,filter_t(xic, [ic_range(1) ic_range(end)], ap.srate));
xlabel('Time (s)');
ylabel('pA');
title('Intracellular');

linkaxes(ax, 'x');

h = figure(2);
set(gcf,'Renderer', 'zbuffer');
ax(1) = subplot(2,1,1);
plot_wt(T, freqs, abs(ec_wt))
title('Extracellular');

ax(2) = subplot(2,1,2);
plot_wt(T, freqs, abs(ic_wt))
title('Intracellular');

linkaxes(ax, 'xy');

% Modulation index calclulations

h = figure(3);
set(h, 'Name', 'Intracellular MI');
lfrange = 1:30;
hfrange = 50:5:250;

[mi phase ~] = sl_mi_grid(xic, ap.srate, lfrange, hfrange);
plot_mod(mi, phase, lfrange, hfrange)

h = figure(4);
set(h, 'Name', 'Extracellular MI');

[mi phase ~] = sl_mi_grid(xec, ap.srate, lfrange, hfrange);
subplot(2,1,1);
plot_mod(mi, phase, lfrange, hfrange);



function [] = plot_wt(T, freqs, wt)
surf(T,freqs, wt);
shading interp;
axis([T(1) T(end) freqs(1) freqs(end) min(min(wt)) max(max(wt))]);
view(0,90);
ylabel('Frequency (Hz)');
xlabel('Time (s)');
caxis;

function [] = plot_mod(mi, phase, lfrange, hfrange)
subplot(2,1,1);
plot_mi(lfrange, hfrange, mi);
title('Modulation index');

subplot(2,1,2);
plot_mi(lfrange, hfrange, phase)
title('Phase');
caxis([-pi pi]);
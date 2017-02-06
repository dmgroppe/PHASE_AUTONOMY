function [] = sz_test(sz_name, ch)

data_path = make_data_path(sz_name, 'data');
pt_name = strtok(sz_name, '_');
cfg = cfg_default();
cfg.freqs = [6 10 20 30 60 100];
cfg.useFilterBank = true; 

[~, bad_b_channels] = bad_channels_get(pt_name);

if ~exist(data_path, 'file')
    error('files does not exist');
end

load(data_path);

T = (0:(length(matrix_bi)-1))/Sf;

figure;clf;
nplots = 5;
ax(1) = subplot(nplots,1,1);
F = f_compute(matrix_bi, Sf, cfg,ch,bad_b_channels);
surf(T,cfg.freqs,F);
axis([0 T(end) cfg.freqs(1), cfg.freqs(end) zlim]);
view(0,90);
shading interp;

ax(2) = subplot(nplots,1,2);
plot(T,matrix_bi(:,ch));
title('iEEG');

ax(3) = subplot(nplots,1,3);
plot(T,F);
hleg = legend(num2str(cfg.freqs'));
set(hleg, 'FontSize', 6);
title('Individual precursor values');

ax(4) = subplot(nplots,1,4);
% This is actually not correct
%f = mean(F,1);
f = exp(mean(log(F),1));
f = p_norm(f',0.01)';
plot(T,f);
title('Mean precursor values');

ax(5) = subplot(nplots,1,5);
  
ls = length(f);
t = fix((0.1*ls):(0.9*ls)); % Obviate any edge effects
zS = (f-min(f(t)))/std(f(t));
pS = zS - min(zS(t));
x = pS./max(pS);

cla;
cfg.stats.window = 1;             % Time window over which to compute stats
cfg.stats.poverlap = 0;             % Percentage overlap of the time windows
cfg.stats.nsurr = 10;
cfg.stats.maxiter = 1;
cfg.stats.alpha = 0.01;
cfg.stats.use_fdr = 0;
cfg.stats.stringent = 0;
cfg.stats.tcond = {'L','R'};
cfg.stats.mint = 10; % Stats are done only after this time (s)
cfg.stats.bias = 0.03;
cfg.stats.lbp = 1;
cfg.stats.sm_window = 1; % smoothing window in seconds
cfg.stats.global_p = true;
cfg.stats.use_max = 0;
cfg.stats.plot_onsets = 1;
cfg.stats.min_sz = 2;

[hp, A, U, pval, surr_A] = change_detect(x, cfg.stats.bias, Sf*cfg.stats.sm_window,...
                cfg.stats.nsurr, cfg.stats.lbp, 0);
plot(T,U);
hold on;
hp_points =size(hp,1);
for i=1:hp_points
    plot((hp(i,1):hp(i,2))/Sf, U(hp(i,1):hp(i,2)), '.g', 'LineStyle', 'none', 'MarkerSize', 3);
end
hold off
title('Page-Hinkley');

linkaxes(ax, 'x');

fname = sprintf('%s_CH%d', sz_name, ch);
set(gcf, 'Name', fname);



function [F] = f_compute(d, srate, cfg, ch, bad)

[npoints, nchan] = size(d);

wt = zeros(length(cfg.freqs), npoints, nchan);

if cfg.useFilterBank
    wt = filterBank(d, cfg.fband, srate, 1000);
else
    for i=1:nchan
        if isempty(find(i == bad, 1))
            wt(:,:,i) = twt(d(:,i), srate, linear_scale(cfg.freqs,srate), cfg.wt_bw);
        end 
    end
end

F = zeros(length(cfg.freqs),npoints);
for i=1:nchan
    if i ~= ch && isempty(find(i == bad, 1))
        f = precursor(wt(:,:,ch), wt(:,:,i), srate, cfg);
        F = F + f;
    end
end


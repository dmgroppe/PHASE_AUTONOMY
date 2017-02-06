function [pac, pc, pk, corr, clfrange] = sl_trpac_v3(x, trange, srate, chlabels, dostats)

% Performs time resolved PAC as per Cohen 2008 "Assessing transient
% cross-frequency coupling in EEG data" J. Neurosci Meth 168:494-499
% Then plot PAC vs PC to look for correlations in the two metrics

% Taufik A Valiante (2014)


if nargin < 5; chlabels = {'CH1', 'CH2'}; end;
if nargin < 6; dostats = 0; end;

ap = sl_sync_params();

[nchan, ~] = size(x);

if nchan < 2
    display('Need two channels for this analysis');
    return;
end

T = (0:(length(x)-1))/srate;
tindex = find(T >= trange(1) & T < trange(2));
X = x(:,tindex); % Just use a subregion of the data
t = T(tindex);

% Compute emvelopes for the high-frequency activity
parfor i=1:nchan
    env(i,:) = envelope(X(i,:), ap.trpac.hfrange, srate);
end

% Get low-frequency peaks in the envelopes
for i=1:nchan
    [pk.loc_env(i), pk.val_env(i)] = get_lf_peaks(env(i,:), srate, ap.trpac.lfrange);
end

% Compute the optimal low-freqeuncy range over which to filter envelopes
% and LFP for PAC calculation

clfrange = [min(pk.loc_env)-ap.trpac.ftol max(pk.loc_env)+ap.trpac.ftol];
display(sprintf('Computed low frequency range for filtering is %6.1f-%6.1fHz', clfrange(1), clfrange(2)));
lf_filter = window_FIR(clfrange(1), clfrange(2), srate);
N = lf_filter.Numerator;

parfor i=1:nchan
    hf_h(i,:) = hilbert(filtfilt(N, 1, env(i,:)));
    lf_h(i,:) = hilbert(filtfilt(N,1, X(i,:)));
    pac(i,:) = phase_coh(hf_h(i,:), lf_h(i,:), clfrange, ap.trpac.ncycles, srate);
end

% Truncte to the right length
%pac = pac(:,1:length(tindex));

% Compute the phase coherence between the low frequency oscillations
pc = phase_coh(lf_h(1,:), lf_h(2,:), clfrange, ap.trpac.ncycles, srate);
%pc = pc(1:length(tindex));


% Compute the low frequency peaks in LFP
for i=1:nchan
    [pk.loc_lfp(i), pk.val_lfp(i)] = get_lf_peaks(X(i,:), srate, ap.trpac.lfrange);
end

if dostats
    hs(1,:,1) = hf_h(1,:);
    hs(2,:,1) = lf_h(1,:);
    
    hs(1,:,2) = hf_h(2,:);
    hs(2,:,2) = lf_h(2,:);
    
    hs(1,:,3) = lf_h(1,:);
    hs(2,:,3) = lf_h(2,:);
    
    tic
    display('Running surrogates...')
    parfor i=1:3
        surr(:,:,i) = bootstrap(squeeze(hs(:,:,i)), ap.trpac.nsurr, clfrange, ap.trpac.ncycles, srate);
    end
    toc
end

for i=1:nchan
    subplot(3,3,(i-1)*3+1);
    [ps_hf, ~, ~] = powerspec(env(i,:), srate, srate);
    [ps_lfp, w, ~] = powerspec(X(i,:), srate, srate);
    ind = find(w <= ap.trpac.ps_lfrange);
    loglog(w(ind),ps_hf(ind), w(ind), ps_lfp(ind));
    title(sprintf('%s: PS HF env %d-%d Hz', chlabels{i}, ap.trpac.hfrange(1), ap.trpac.hfrange(2)));
    xlabel('Feqs (Hz)');
    ylabel('Power');
    legend({'HF env', 'LFP'});
    set(gca, 'TickDir', 'out');
    axis square;
    
    % Plot the peak values env power in the low frequency range
    hold on;
    plot(pk.loc_env(i), pk.val_env(i), '.r')
    hold off;
    
    hold on;
    plot(pk.loc_lfp(i), pk.val_lfp(i), '.r')
    hold off;
    
    axis([0 ap.trpac.ps_lfrange ylim]);
end

% Plot PAC and PC (and then together)
% -- CH1
ax(1) = subplot(3,3,2);

if ap.trpac.fz_norm
    zpac1 = fisherZ(pac(1,:));
else
    zpac1 = pac(1,:);
end

plot(t,smooth(zpac1, ap.srate));
if dostats
    plot_ts(t, zpac1', surr(:,:,1), ap.trpac.alpha, ap.trpac.stringent, [0 2]);
end
xlabel('Time (s)');
ylabel('PAC');
title(['zPAC - ' chlabels{1}]);
if ~isempty(ap.trpac.ylim)
    axis([t(1) t(end) ap.trpac.ylim]);
end
set(gca, 'TickDir', 'out');
axis square;

% ---- CH2
ax(2) = subplot(3,3,5);

if ap.trpac.fz_norm
    zpac2 = fisherZ(pac(2,:));
else
    zpac2 = pac(2,:);
end

plot(t, smooth(zpac2, ap.srate));
if dostats
    plot_ts(t, zpac2', surr(:,:,2), ap.trpac.alpha, ap.trpac.stringent, [0 2]);
end
xlabel('Time (s)');
ylabel('PAC');
title(['zPAC - ' chlabels{2}]);
if ~isempty(ap.trpac.ylim)
    axis([t(1) t(end) ap.trpac.ylim]);
end
set(gca, 'TickDir', 'out');
axis square;

% ---- PC
ax(3) = subplot(3,3,8);

if ap.trpac.fz_norm
    zpc = fisherZ(pc);
else
    zpc = pc;
end

plot(t, smooth(zpc, ap.srate));
if dostats
    plot_ts(t, zpc', surr(:,:,3), ap.trpac.alpha, ap.trpac.stringent, [0 2]);
end
xlabel('Time (s)');
ylabel('PC');
title('zPC');
if ~isempty(ap.trpac.ylim)
    axis([t(1) t(end) ap.trpac.ylim]);
end
set(gca, 'TickDir', 'out');
axis square;

% Combined plot
ax(4) = subplot(3,3,9);
plot(T(tindex), smooth(zpac1,srate), T(tindex), ...
    smooth(zpac2,srate), T(tindex), smooth(zpc,srate));
xlabel('Time (s)');
ylabel('PC');
title('zPC');
legend({['PAC' chlabels{1}],['PAC' chlabels{2}],'PC'});

if ~isempty(ap.trpac.ylim)
    axis([t(1) t(end) ap.trpac.ylim]);
end
linkaxes(ax, 'x');
set(gca, 'TickDir', 'out');
axis square;

% ---- Plot the raw data
hp = hp_filter(1, srate, 1000);

ax(4) = subplot(3,3,7);
plot(t, filtfilt(hp.Numerator,1,X(1,:)), t, filtfilt(hp.Numerator, 1, X(2,:)) - 0.25);
xlabel('Time (s)');
ylabel('mV');
title('Raw data')
legend(chlabels);
set(gca, 'TickDir', 'out');
axis([t(1) t(end) ylim]);

% Plot the correlations between PAC and PC
subplot(3,3,3);
[corr.rho(1), corr.pval(1) corr.pac(1,:) corr.pc] = plot_correlation(zpac1, zpc, ap, srate);
xlabel('PAC');
ylabel('PC')
set(gca, 'TickDir', 'out');
%title(upper(chlabels{1}));
axis square;
if ~isempty(ap.trpac.ylim)
    axis( [ap.trpac.ylim ap.trpac.ylim]);
end

subplot(3,3,6);
[corr.rho(2), corr.pval(2), corr.pac(2,:) ~] = plot_correlation(zpac2, zpc, ap, srate);
xlabel('PAC');
ylabel('PC')
set(gca, 'TickDir', 'out');
%title(upper(chlabels{2}));
axis square;
if ~isempty(ap.trpac.ylim)
    axis( [ap.trpac.ylim ap.trpac.ylim]);
end

function [env] = envelope(x, frange, srate)
d = window_FIR(frange(1), frange(2), srate);
env = abs(hilbert(filtfilt(d.Numerator, 1, x)));

function [rho pval xs ys] = plot_correlation(x, y, ap, srate)

win = ap.trpac.window*srate;
npoints = length(x);
ind = 1:win:(npoints-win);
for i=1:length(ind)
    xs(i) = mean(x(ind(i):(ind(i)+win-1)));
    ys(i) = mean(y(ind(i):(ind(i)+win-1)));
end

plot(xs, ys, '.', 'MarkerSize', 5, 'LineStyle', 'none');
[rho, pval] = corr(xs', ys', 'type', 'Spearman');
title(sprintf('rho = %6.4f, pval = %6.4e', rho, pval));

np = length(xs);
X = [ones(1,np)' xs'];
b = regress(ys',X);
xfit = min(xs):0.051:max(xs);
yfit = b(1) + b(2)*xfit;

hold on;
plot(xfit, yfit, 'r');
hold off;

function [pk_loc, pk_val] = get_lf_peaks(x, srate, lfrange)

[ps, w, ~] = powerspec(x, srate, srate);

% Find the maxima in the PS in the LF range (specified as input)
ind = find(w>= lfrange(1) & w <= lfrange(2));
[~, loc] = findpeaks(ps(ind));
if ~isempty(loc)
    pmax = max(ps(ind(loc)));
    pind = find(ps(ind) == pmax);
    if pind ~= 1 || pind ~= length(ind)
        pk_loc = w(ind(pind));
        pk_val = ps(ind(pind));
    else
        pk_loc = mean(lfrange);
        pk_val = ps(closest(w,pk_loc));
    end 
else
    pk_loc = mean(lfrange);
    pk_val = ps(closest(w,pk_loc));
end

function [idx] = closest(a, val)
[~, idx] = min(abs(a - val));

function [surr] = bootstrap(h, nsurr, lfrange, ncycles, srate)
% Boot straps the phase coherence metric using the hilbert transforms in
% the two time series in h

npoints = length(h);
surr = zeros(nsurr, npoints);
for i=1:nsurr
    h_surr = rand_rotate(h(1,:));
    surr(i,:) = fisherZ(phase_coh(h_surr, h(2,:), lfrange, ncycles, srate)); 
end

function [sig] = find_sig(surr, v)

nsurr = size(surr,1);
c = zeros(1,length(v));
for i=1:nsurr
    c = c + (surr(i,:) > v);
end
sig = c/nsurr;

function [] = plot_ts(t, y, surr, alpha, stringent, ylim)
if nargin < 6; ylim = []; end;

sig = find_sig(surr, y);
sig_fdr = fdr_vector(sig, alpha, stringent);

sig_ind = find(sig_fdr == 1);
hold on;
plot(t(sig_ind), y(sig_ind), '.r', 'LineStyle', 'none', 'MarkerSize', 2);
hold off;

if ~isempty(ylim)
    axis([t(1) t(end) ylim]);
end



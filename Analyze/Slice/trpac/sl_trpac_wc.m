function [] = sl_trpac_wc(x, trange, srate, chlabels, dostats)

% Performs time resolved PAC as per Cohen 2008 "Assessing transient
% cross-frequency coupling in EEG data" J. Neurosci Meth 168:494-499
% Then plot PAC vs PC to look for correlations in the two metrics


if nargin < 5; chlabels = {'CH1', 'CH2'}; end;
if nargin < 6; dostats = 0; end;

ap = sl_sync_params();

[nchan, ~] = size(x);

if nchan < 2
    display('Need two channels for this analysis');
    return;
end

T = (0:(length(x)-1))/srate;
tindex = find(T >= trange(1) & T <= trange(2));
X = x(:,tindex); % Just use a subregion of the data
t = T(tindex);
nfreq = length(ap.trpac.wt_lfrange);

% Compute emvelopes for the high-frequency activity
parfor i=1:nchan
    env(:, i) = envelope(X(i,:), ap.trpac.hfrange, srate);
    env_wt(:,:,i) = twt(env(:,i), srate, linear_scale(ap.trpac.wt_lfrange, srate), ap.trpac.wt_bw);
end

for i=1:nchan
    lfp_wt(:,:,i) = twt(X(i,:), srate, linear_scale(ap.trpac.wt_lfrange, srate), ap.trpac.wt_bw);
end

parfor c=1:nchan
    for f=1:nfreq
        pac(f,:, c) = phase_coh(squeeze(lfp_wt(f,:,c)), squeeze(env_wt(f,:,c)), ap.trpac.wt_lfrange(f), ap.trpac.ncycles, srate);
    end
end

for f=1:nfreq
    pc(f,:) = phase_coh(lfp_wt(f,:, 1), lfp_wt(f,:,2), ap.trpac.wt_lfrange(f), ap.trpac.ncycles, srate);
end

%% ---------------------- Compute the correlations
win = ap.trpac.window*srate;
ind = 1:win:(length(pc)-win);
for i=1:length(ind)
    mpc(:,i) = mean(pc(:,ind(i):(ind(i)+win-1)), 2);
    mpac(:,i,:) = mean(pac(:,ind(i):(ind(i)+win-1), :), 2);
end


for i=1:nfreq
    [rho1(i), pval1(i)] = corr(squeeze(mpc(i,:))', squeeze(mpac(i,:,1))', 'type', 'Spearman');
    [rho2(i), pval2(i)] = corr(squeeze(mpc(i,:))', squeeze(mpac(i,:,2))', 'type', 'Spearman');
end

clf;
ax(1) = subplot(2,1,1);
plot(ap.trpac.wt_lfrange, rho1);

ax(2) = subplot(2,1,2);
plot(ap.trpac.wt_lfrange, rho2);


function [x] = average(x,win)
c   = cumsum(x)./win;
x   = [c(win); c((win+1):end)-c(1:(end-win))];

function [env] = envelope(x, frange, srate)
d = window_FIR(frange(1), frange(2), srate);
env = abs(hilbert(filtfilt(d.Numerator, 1, x)));

function [pac] = phase_coh(h1, h2, freq, ncycles, srate)
h1=h1(:);
h2=h2(:);

R = h1.*conj(h2)./(abs(h1).*abs(h2));
win = fix(ncycles/mean(freq)*srate);
t = padarray(R,[fix(win/2)+1 0],'replicate');
pac = abs(average(t,win));
pac = pac(1:length(h1));

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



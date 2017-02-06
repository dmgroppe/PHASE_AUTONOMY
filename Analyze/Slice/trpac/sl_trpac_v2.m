function [pac] = sl_trpac_v2(x, hfrange, lfrange, T, trange, srate, chlabels)

% Performs time resolved PAC as per Cohen 2008 "Assessing transient
% cross-frequency coupling in EEG data" J. Neurosci Meth 168:494-499
% Then plot PAC vs PC to look for correlations in the two metrics

if nargin < 7; chlabels = {'CH1', 'CH2'}; end;

[nchan, ~] = size(x);

if nchan < 2
    display('Need two channels for this analysis');
    return;
end

tindex = find(T >= trange(1) & T <= trange(2));

ncycles = 10; % Number of cycles of low freq to average over
X = x(:,tindex); % Just use a subregion of the data

% Compute PAC, adn store the LF phase to compute the phase coherence
lf_filter = window_FIR(lfrange(1), lfrange(2), srate);
N = lf_filter.Numerator;

parfor i=1:nchan
    env(i,:) = envelope(X(i,:), hfrange, srate);
    hf_h = hilbert(filtfilt(N, 1, env(i,:)));
    lf_h(i,:) = hilbert(filtfilt(N,1, X(i,:)));
    pac(i,:) = phase_coh(hf_h, lf_h(i,:), lfrange, ncycles, srate);
end

% Truncte to the right length
pac = pac(:,1:length(tindex));

% Compute the phase coherence between the low frequency oscillations
pc = phase_coh(lf_h(1,:), lf_h(2,:), lfrange, ncycles, srate);
pc = pc(1:length(tindex));

figure(1);clf;
for i=1:nchan
    subplot(3,3,(i-1)*3+1);
    [ps_hf, w, ~] = powerspec(env(i,:), srate, srate);
    [ps_lfp, w, ~] = powerspec(X(i,:), srate, srate);
    ind = find(w <=30);
    loglog(w(ind),ps_hf(ind), w(ind), ps_lfp(ind));
    title(sprintf('%s: Power spectrum of high frequency envelope %d-%d Hz', chlabels{i}, hfrange(1), hfrange(2)));
    xlabel('Feqs (Hz)');
    ylabel('Power');
    legend({'hf envelope', 'LFP'});
    
    % Find the maxima in the PS in the LF range (specified as input)
    ind = find(w>= lfrange(1) & w <= lfrange(2));
    [~, loc] = findpeaks(ps_hf(ind));
    if ~isempty(loc)
        pk_env(i) = w(min(ind(loc)));
        hold on;
        plot(pk_env(i), ps_hf(min(ind(loc))), '.r')
        hold off;
    else
        pk_env(i) = mean(lfrange);
    end
    
    
    [~, loc] = findpeaks(ps_lfp(ind));
    if ~isempty(loc)
        pk_lfp(i) = w(min(ind(loc)));
        hold on;
        plot(pk_lfp(i), ps_lfp(min(ind(loc))), '.r')
        hold off;
    else
        pk_lfp(i) = mean(lfrange);
    end 

end

% Plot PAC and PC (and then together)
ax(1) = subplot(3,3,2);
plot(T(tindex), smooth(fisherZ(pac(1,:)),srate));
xlabel('Time (s)');
ylabel('PAC');
title(sprinf('Z transformed PAC - %s', chlabels{1}));

ax(2) = subplot(3,3,5);
plot(T(tindex), smooth(fisherZ(pac(2,:)),srate));
xlabel('Time (s)');
ylabel('PAC');
title(sprinf('Z transformed PAC - %s', chlabels{2}));

ax(3) = subplot(3,3,8);
plot(T(tindex), smooth(fisherZ(pc),srate));
xlabel('Time (s)');
ylabel('PC');
title('Z transformed PC');

ax(4) = subplot(3,3,9);
plot(T(tindex), smooth(fisherZ(pac(1,:)),srate), T(tindex), ...
    smooth(fisherZ(pac(2,:)),srate), T(tindex), smooth(fisherZ(pc),srate));
xlabel('Time (s)');
ylabel('PC');
title('Z transformed PC');
legend({['PAC' chlabels{1}],['PAC' chlabels{1}],'PC'});

linkaxes(ax, 'x');

% Plot the correlations between PAC and PC
subplot(3,3,3);
plot_correlation(fisherZ(squeeze(pac(1,:))), fisherZ(pc));

subplot(3,3,6);
plot_correlation(fisherZ(squeeze(pac(2,:))), fisherZ(pc));

function [x] = average(x,win)
c   = cumsum(x)./win;
x   = [c(win); c((win+1):end)-c(1:(end-win))];

function [env] = envelope(x, frange, srate)
d = window_FIR(frange(1), frange(2), srate);
env = abs(hilbert(filtfilt(d.Numerator, 1, x)));

function [pac] = phase_coh(h1, h2, lfrange, ncycles, srate)
R = h1.*conj(h2)./(abs(h1).*abs(h2));
win = fix(ncycles/mean(lfrange)*srate);
t = padarray(R',[fix(win/2)+1 0],'replicate');
pac = abs(average(t,win));

function [] = plot_correlation(zpac, zpc)
plot(zpac, zpc, '.', 'MarkerSize', 1, 'LineStyle', 'none');
xlabel('PAC');
ylabel('PC')
[rho, pval] = corr(zpac', zpc, 'type', 'Spearman');
title(sprintf('rho = %6.4f, pval = %6.4e', rho, pval));
function [sync] = sync_2ts(ts1, ts2, freqs, srate, atype, nsurr, nbins, wnumber)

% USAGE: sync_compare_2pairs_circ(EEG, p1, p2, ap)
%
% Computes significance between channel pairs by partioning the epoch
% in to sub-epochs which are specified in ap.  The synchronization is
% computed for specified frequencies for each epochs and compared using K-S to obtain p-values, which
% are then fdr corrected to determine significance.

if nargin < 6; nsurr = 0; end;
if nargin < 7; nbins = 12; end;
if nargin < 8; wnumber = 5; end;

wt1 = twt(ts1, srate, linear_scale(freqs, srate), wnumber);
wt2 = twt(ts2, srate, linear_scale(freqs, srate), wnumber);

fh = sync_fh(atype);

% Cycle over the frequencies

for i=1:length(freqs)
    sync(i) = fh(wt1(i,:), wt2(i,:));  
end

clf('reset');
set(gcf, 'Name', 'Two channel sync');
subplot(2,1,1);
plot(freqs, abs(sync));
xlabel('Frequency (Hz)');
ylabel(atype);

% Do the statistics

if nsurr
    parfor i=1:nsurr
        surr_sync(:,i) = surrogate_sync(wt1, wt2, fh);
    end
    
    count = zeros(1,length(sync));
    for i=1:nsurr
        count = count + (surr_sync(:,i)' > sync);
    end
    
    p = (count + 1)/(nsurr + 1);
    sig = fdr_vector(p,0.05,true);
    
    if max(sig)
        hold on;
        for i=1:length(sig)
            if sig(i)
                plot(freqs(i),sync(i), '.', 'LineStyle', 'None', 'MarkerSize', 15);
            end
        end
        hold off;
    end
end

% Do the phase-dependant power correlations

for i=1:length(freqs)
    [~, ~, rho(i,:), prho(i,:), ~, mean_phase(i)] = sync_ppc(wt1(i,:), wt2(i,:), nbins);
end

subplot(2,1,2);
ap = sync_cc_params();
ap.freqs = freqs;
ap.pl.ranges = false;
ap.pl.show_axes = true;
ap.pl.colorbar = true;
ap.pl.zeroline = false;

[~,x] = make_phase_bins(nbins);
plot_ppc(x, rho, ap);


function [ssync] = surrogate_sync(wt1, wt2, fh)

nfreqs = size(wt1, 1);
for j=1:nfreqs
    surr = rand_rotate(wt1(j,:));
    ssync(j) = fh(surr, wt2(j,:));  
end


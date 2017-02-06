function [] = sync_fdepen_matrix(EEG, chtoexcl, ptname, cond)

ap = sync_params();

ts = data_retrieve(EEG, cond, ap.length, ptname);

% Set the channels to exclude to zero - easier than indexing the excluded
% channels

ts(chtoexcl, :) = 0;
[nchan, npoints] = size(ts);
ts(nchan,:) = [];  % Remove the trigger channel
nchan = nchan - 1;

freqs = ap.freqs;
nfreq = length(freqs);
srate = EEG.srate;
wnumber = ap.wnumber;

parfor i=1:nchan
    wt(:,:,i) = twt(ts(i,:), srate, linear_scale(freqs, srate), wnumber);
end

fh = sync_fh(ap.atype);

sync = zeros(nchan, nchan, length(freqs));

for i=1:length(freqs);
    sync(:,:,i) = sync_m(fh,wt,i);
end

% Shuffle the time series and redo the same calculation.

shuffle = unique(fix(rand(1,5*nchan)*npoints));

for i=1:nchan
    surr_ts(i,:) = rand_rotate(ts(i,:), shuffle(i));
end

for i=1:nchan
    wt(:,:,i) = twt(surr_ts(i,:), srate, linear_scale(freqs, srate), wnumber);
end

% Compute the surrogate matrix - with 64 chan there are > 1000 surrogates.
% Should check here to see how many surrogates I het for the number of chan
% and make the appropriate surrogates


display('Computing surrogates')

parfor i=1:nfreq
    surr_sync(:,:,i) = sync_m(fh,wt,i);
end

% Compute the probabilities for the sync matrix

% Colect the surrogates in a vector

for ii = 1:nfreq
    count = 0;
    for i=1:nchan
        for j=i+1:nchan
            count = count+1;
            surr(count,ii) = surr_sync(j,i,ii);
        end
    end
end

% Restrict to the number of specified surrogates
surr = surr(1:ap.nsurr,:);
sig_count = zeros(nchan, nchan,nfreq);
for i=1:nfreq
    for j=1:nchan
        for k=j+1:nchan
            sig_count(k,j,i)=length(find(surr(:,i) > sync(k,j,i)));
        end
    end
end

% Compute the p-values
p = (sig_count+1)/(ap.nsurr+1);

% Exclude r and c of channels to exclude
p(chtoexcl,:,:) = 0.5;
p(:,chtoexcl,:) = 0.5;

for i=1:nfreq
    sig(:,:,i) = FDR_corr(p(:,:,i), ap.alpha, ap.fdr_stringent);
    nsig_chan(i) = length(find(sig(:,:,i) == 1 ));
end

h = figure(1);
ymax = max(nsig_chan);
fname = sprintf('Freq dep maxtrix - %s %s', upper(ptname), upper(cond));

if ymax ~= 0
    plot(freqs, nsig_chan/ymax);
    axis([freqs(1) freqs(end) 0 1]);
    ylabel('Normalized connnections');
    xlabel('Frequency (Hz)');    
else
    display('No network connections for this condition');
end

save_figure(h,get_export_path_SMA(), fname);
save([get_export_path_SMA() fname '.mat'], 'sync', 'surr_sync', 'ap', 'nsig_chan', 'sig_count');

% Crete the sync matrix

function [r] = sync_m(fh,wt, freq)
nchan = size(wt,3);

r = zeros(nchan, nchan);

for j=1:nchan
    for k = j+1:nchan
       r(k,j) = fh(wt(freq,:,j), wt(freq,:,k));
    end
end
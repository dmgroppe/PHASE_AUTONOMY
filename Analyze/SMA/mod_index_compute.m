function [MI, KS] = mod_index_compute(x, srate, lowfs, highfs, nbin, wn, usewt)

env_highfs = abs(get_spectra(x, highfs, srate, wn, usewt));
phases_lowfs = angle(get_spectra(x, lowfs, srate, wn, usewt));

nhighfs = size(env_highfs,2);
nlowfs = size(phases_lowfs,2);

MI = zeros(nhighfs, nlowfs);
%KS = zeros(nhighfs, nlowfs);

amp_dists = zeros(nbin, nhighfs, nlowfs);
for i=1:nhighfs
    %fprintf('Working on %d of %d high frequencies\n', i, nhighfs-1);
    for j=1:nlowfs
        comp(1,:) = phases_lowfs(:,j);
        comp(2,:) = env_highfs(:,i)/std(env_highfs(:,i));
        %comp(2,:) = env_highfs(:,i);
        amp_dists(:,i,j) = amp_dist(comp, nbin);
    end
end

% Nomalize all the amp distribution so that their mean hights are the same
% Normalized to the max mean height

diffs = max(max(mean(amp_dists, 1))) - mean(amp_dists, 1);
diffs = repmat(diffs,nbin,1);
amp_dists = amp_dists + diffs;

% Uniform distribution probabilities
Q = ones(nbin,1)/nbin;

for i=1:nhighfs
    for j=1:nlowfs
        P = amp_dists(:,i,j)/sum(amp_dists(:,i,j));
        MI(i,j) = KL_distance(P,Q)/log10(nbin);
        plot(P);
        
        %Compute two sample kolmogorov-Smirnov test statistic
        [KS.h(i,j), KS.p(i,j)] = kstest2(Q, P);
    end
end


function [spectra]= get_spectra(x, freqs, srate, wn, usewt)
if usewt
    spectra = twt(x,srate, linear_scale(freqs, srate), wn)';
else
    for i=1:length(freqs)-1
        d = window_FIR(freqs(i), freqs(i+1), srate);
        spectra(:,i) = hilbert(filtfilt(d.Numerator, 1, x));
    end
end


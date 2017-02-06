function [bins, centers, amps] = sync_peh(lf_phase, hf_env, nbins, dop)

if nargin < 4; dop = 0; end;

% Generate Phase Envelope Histogram

[bins, centers] = make_phase_bins(nbins);

for i=1:length(bins)
    ind = find(lf_phase >= bins(1,i) & lf_phase < bins(2,i));
    amps{i} = hf_env(ind);
    mean_amps = mean(amps{i});
end

uniform = ones(1,length(centers))*mean(mean_amps);
MI = KL_distance(mean_amps, uniform)/log(length(centers));


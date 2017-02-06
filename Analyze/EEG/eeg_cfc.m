function [r, p] = eeg_cfc(lf_phase, hf_env, nbins)

% Generate Phase Envelope Histogram

[bins, centers] = make_phase_bins(nbins);

amps = get_amps(lf_phase, hf_env, bins);
r = circ_r(centers,amps);
p = circ_rtest(centers,amps);

function [amps] = get_amps(lf_phase, hf_env, bins)

nbins = length(bins);
amps = zeros(1,nbins);

for i=1:nbins
    ind = find(lf_phase >= bins(1,i) & lf_phase < bins(2,i));
    if ~isempty(ind)
        amps(i) = mean(hf_env(ind));
    else
        amps(i) = 0;
    end
end





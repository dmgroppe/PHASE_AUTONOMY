function [MI, p, surr_mi] = sync_mi(lf_phase, hf_env, nbins, nsurr, dop, ap)

% lf_phase - low frequency phase
% hf_env - high frequency envelope
% nbins - number of phase bins
% nsurr - number of surrogates for statistical testing
% dop - do stats
% ap - 'application parameters' - bunch of defaults

% Taufik A Valiante (2014)

if nargin < 6; ap = sync_params(); end;
if nargin < 5; dop = 0; end;
if nargin < 4; nsurr = 0; end;

% Generate Phase Envelope Histogram

[bins, centers] = make_phase_bins(nbins);

[mean_amps ninds] = get_amps(lf_phase, hf_env, bins);
uniform = ones(1,length(centers))*mean(mean_amps);
[MI] = getMI(centers, mean_amps, ninds, uniform);

if dop
    surr_mi = zeros(1,nsurr);
    for i=1:nsurr
        if ap.scramble_phase
            rot_hf_env = scramble_phase(hf_env);
        else
            rot_hf_env = rand_rotate(hf_env);
        end
        [surr_amps, ~] = get_amps(lf_phase, rot_hf_env, bins);
        suniform = ones(1,length(centers))*mean(surr_amps);
        surr_mi(i) =  KL_distance(surr_amps, suniform)/log10(length(centers));
    end
    p = (length(find(surr_mi > MI.tort))+1)/(nsurr+1);
    surr_mi = mean(surr_mi);
else
    p = 1;
    surr_mi = [];
end

function [mean_amps ninds] = get_amps(lf_phase, hf_env, bins)

nbins = length(bins);
mean_amps = zeros(1,nbins);
ninds = mean_amps;

for i=1:nbins
    ind = find(lf_phase >= bins(1,i) & lf_phase < bins(2,i));
    if ~isempty(ind)
        mean_amps(i) = mean(hf_env(ind));
        ninds(i) = length(ind);
    else
        mean_amps(i) = 0;
        ninds(i) = 0;
    end
end

function [MI] = getMI(centers, mean_amps, ninds, uniform)
MI.tort = KL_distance(mean_amps, uniform)/log10(length(centers));
MI.phase = angle((ninds.*mean_amps)*exp(1i*centers'));
%b = nlinfit(centers, mean_amps, @vm_1, [0 1 0]);
%MI.phase = b(2);
%scatter(centers, mean_amps);



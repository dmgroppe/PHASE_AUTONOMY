function [instf] = ifreq(imf, srate)

% Computes the instantaneous frequency from a time series.  If it is real
% it is assumed to be an IMF.  If it is complex it is assumed to be the
% hilbert transform of an imf.

% Unwrap the phases

if ~isreal(imf)
    ph = unwrap(angle(imf));
else
    ph = unwrap(angle(hilbert(imf)));
end

dph = diff(ph);

% Look for steps - negative phase differences - since the unwrap should
% give a monotonically increasing function of phase angle
negs = find(dph < 0);
sph = ph;

% Shift the phis at each step to make continuous
for i=1:numel(negs)
    ind = negs(i);
    %sph(ind+1:end) = sph(ind+1:end) + abs(sph(ind+1)-sph(ind));
    sph(ind+1:end) = sph(ind+1:end) + 2*pi;
end

% Calculate the instantaneous frequency
instf = diff(sph)/(2*pi)*srate;
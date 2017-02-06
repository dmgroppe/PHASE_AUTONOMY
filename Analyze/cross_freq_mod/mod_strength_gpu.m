function [ms] = mod_strength_gpu(wt, mod_phase)

%   Usage:
%       [ms] = mod_strength(wt, mod_phase)
%   Computes the modulation strength
%   Input:
%       x               Complex valued wavelet spectrum
%       params          Analysis parameters
%       mod_pahse       Modulation phase(phases where modulation is
%                       greatest) - this is precomputed
%   Output:
%       ms              Matrix of modulation strengths for all possible
%                       frequency combinations
%
% Copyright (C) Taufik A Valiante 2011



[nfreq ~] = size(wt);

ms = zeros(nfreq, nfreq);

phases = angle(wt);
amps = abs(wt);
mp_angle = angle(mod_phase);

for f1=1:nfreq
    for f2=(f1+1):nfreq
        lfEnv = amps(f1,:).*cos(phases(f1,:)-mp_angle(f2,f1));
        ms(f2,f1) = pearson_corr(lfEnv, amps(f2,:));
    end
end
ms = fisherZ(ms);
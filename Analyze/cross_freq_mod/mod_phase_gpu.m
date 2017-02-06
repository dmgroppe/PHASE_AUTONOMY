function [mp] = mod_phase_gpu(wt)

%   Computes the modulation phase - average phase at which a higher
%   frequency is maximally modulated by a lower frequency
%   Input:
%       x               complex valued wavelet spectrum
%       params          analysis parameters
%   Output:
%       mp              matrix of modulation phases of all possible
%                       frequency combinations
%
% Copyright(C) Taufik A Valiante 2011

nfreq = size(wt,1);

mp = zeros(nfreq, nfreq);
phases = angle(wt);
amps = abs(wt);

for f1=1:nfreq
    phasem = repmat(phases(f1,:),nfreq,1);
    z = amps.*exp(1i*phasem);
    m_raw = mean(z,2);  
    for f2=(f1+1):nfreq
        mp(f2,f1)= m_raw(f2);
    end
end
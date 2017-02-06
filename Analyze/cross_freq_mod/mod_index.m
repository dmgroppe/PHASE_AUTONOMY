function [mi] = mod_index(wt)

%   Computes the normalized modulation strength (modulation index
%   Input:
%       x               complex valued wavelet spectrum
%       params          analysis parameters
%       numsurrogate    number of surrogates to normalize
%   Output:
%       mi              matrix of modulation strength of all possible
%                       frequency combinations



[nfreq npoints] = size(wt);

mi = zeros(nfreq, nfreq);

for i=1:nfreq
    phase=angle(wt(i,:));
    for j=i+1:nfreq
        amplitude=abs(wt(j,:));
        z=amplitude.*exp(i*phase);
        mi(i,j)=mean(z);
    end
end
    
%USAGE: [mp ms] = cross_freq_mod(wspectra)
%   Computes the cross frequency modulation from a set of wavelet spectra
%
%   INPUT:
%       wspectra:   3D matrix of spectra
%   OUTPUT:
%       mp:         The modulation phase where modulation in the strongest
%       ms:         Modulation strength
%
%--------------------------------------------------------------------------

function [modphase modstrength] = cross_freq_mod(wspectra)

[nscales, ~, nspectra] = size(wspectra);

mp=zeros(nscales, nscales, nspectra);
ms = zeros(nscales, nscales, nspectra);

parfor i=1:nspectra
    mp(:,:,i) = mod_phase(wspectra(:,:,i));
end
modphase = mean(mp, 3);

parfor i=1:nspectra
    ms(:,:,i) = mod_strength(wspectra(:,:,i),modphase);
end

modstrength = mean(ms,3);





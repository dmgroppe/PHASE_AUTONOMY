function [rho, w] = ps_correlation(x, window, srate, shuffle)

%  Performs correlation of freqeuncies as per Masimore et al. 2004
%  "Measuring fundamental frequencies in local ?eld potentials"
%  Will do stats if shuffle = 1 by randomizing the spectra

% Taufik A Valiante (2012)

if nargin < 4; shuffle = 0; end;

[~, w, pxx] = powerspec(x,window, srate, true, 1.5);
[nspectra nfreq] = size(pxx);

% pxx has all the individual power spectra with pxx(scount, w), and hence
% each row is a psd, hence each column is a separate frequency

pvar = std(pxx);
means = mean(pxx);

rho = zeros(nfreq, nfreq);

for i=1:nfreq
    for j=i+1:nfreq
        for k=1:nspectra
            % loop over all segments
            if shuffle
                s1 = fix(rand*nspectra) + 1;
                s2 = fix(rand*nspectra) + 1;
            else
                s1 = k;
                s2 = k;
            end        
            rho(j,i) = rho(j,i) + (pxx(s1,j) - means(j))*(pxx(s2,i) - means(i));
        end
        rho(j,i) = rho(j,i)/(pvar(i)*pvar(j))/nspectra;
    end
end

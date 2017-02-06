function [pval zval] = circ_pvalue(spectra)

[nfrq npoints nspectra] = size(spectra);
pval = zeros(nfrq, npoints);
zval = pval;
alpha = zeros(1,nspectra);

for f=1:nfrq
    for p = 1:npoints
        alpha = reshape(angle(spectra(f,p,:)), 1, nspectra);
        [pval(f,p), zval(f,p)] = circ_rtest(alpha);
    end
end


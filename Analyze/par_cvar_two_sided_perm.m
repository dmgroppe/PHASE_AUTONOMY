function [p] = par_cvar_two_sided_perm(R1, R2, aparams, dparams)

[~, ~, nspectra1] = size(R1);
[nfrq, npoints, nspectra2] = size(R2);
nsurr = aparams.ana.nsurr;
norm = aparams.ana.normtobl;

nspectra = min([nspectra1 nspectra2]);
blsamples = time_to_samples(dparams.ana.baseline, dparams.data.srate);

spectra = zeros(nfrq, npoints, nspectra*2);
spectra(:,:,1:nspectra) = R1(:,:,1:nspectra);
spectra(:,:,nspectra+1:2*nspectra) = R2(:,:,1:nspectra);

p = zeros(nfrq, npoints);
z = zeros(nfrq, npoints, nspectra);

if (aparams.ana.normtobl)
    z0 = norm_to_bl(abs(sum(R1, 3)),blsamples) - norm_to_bl(abs(sum(R2, 3)), blsamples);
else
    z0 = abs(sum(R1, 3)) - abs(sum(R2,3));
end

tic
parfor i=1:nsurr
    z(:,:,i) = permute(spectra, norm, blsamples);
end
toc

for i=1:aparams.ana.nsurr
    ind = find(z(:,:,i) > z0);
    p(ind) = p(ind) + 1;
end

p = (1+p)./(aparams.ana.nsurr+1);

function [z] = permute(spectra, norm, blsamples)

[~,~,nspectra] = size(spectra);
n2spectra = nspectra/2;

for i=1:nspectra
    index = floor(rand*nspectra) + 1;
    if (index > nspectra)
        index = nspectra;
    end
    temp = spectra(:,:,i);
    spectra(:,:,i) = spectra(:,:,index);
    spectra(:,:,index) = temp;
end

c1 = abs(sum(spectra(:,:,1:n2spectra), 3));
c2 = abs(sum(spectra(:,:,n2spectra+1:nspectra), 3));

if (norm)
    z = norm_to_bl(c1, blsamples)- norm_to_bl(c2, blsamples);
else
    z = c1 - c2;
end



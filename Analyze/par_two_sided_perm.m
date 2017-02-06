%   USAGE: [p] = par_two_sided_perm(R1, R2, atype, aparams, dparams)
%   
%   Input:
%       R1: condition 1 spectra
%       R2: condition 2 spectra
%       atype:  analysis type 'power', 'cvar'
%       aparams, dparams: self explanatory
%   Output:
%       p:  probability of z0 of occuring by chance


function [p] = par_two_sided_perm(R1, R2, atype, aparams, dparams)

nspectra1 = size(R1,3);
[nfrq, npoints, nspectra2] = size(R2);
nsurr = aparams.ana.nsurr;
norm = aparams.ana.norm;

% Take the same number of spectra from each condition so as to not favour
% one over the other
nspectra = min([nspectra1 nspectra2]);

blsamples = time_to_samples(dparams.ana.baseline, dparams.data.srate);

% Combine all the spectra into one large array for permuting
spectra = zeros(nfrq, npoints, nspectra*2);
spectra(:,:,1:nspectra) = R1(:,:,1:nspectra);
spectra(:,:,nspectra+1:2*nspectra) = R2(:,:,1:nspectra);

% Get the test statistic
[z0,~,~] = get_z(R1(:,:,1:nspectra), R2(:,:,1:nspectra), aparams.ana.norm, atype, blsamples);

p = zeros(nfrq, npoints);
z = zeros(nfrq, npoints, nsurr);

tic
parfor i=1:aparams.ana.nsurr
    % Get test statistic for each permutation
    z(:,:,i) = permute(spectra, norm, atype, blsamples);
end
toc

for i=1:aparams.ana.nsurr
    ind = find(z(:,:,i) > z0);
    p(ind) = p(ind) + 1;
end

p = (1+p)./(aparams.ana.nsurr+1);


function [z] = permute(spectra, norm, atype, blsamples)

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

c1 = spectra(:,:,1:n2spectra);
c2 = spectra(:,:,n2spectra+1:nspectra);

[z,~,~] = get_z(c1, c2, norm, atype, blsamples);


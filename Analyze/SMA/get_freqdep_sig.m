function [sig_inc, sig_dec] = get_freqdep_sig(ms_surr, ms, alpha)

[nfreqs nsurr ncond] = size(ms_surr);
ap = sync_params();

pinc = zeros(nfreqs, ncond);
pdec = pinc;

for i=1:1:ncond
    for j =1:nsurr
        index = find(ms_surr(:,j,i) > ms(:,i));
        pinc(index,i) = pinc(index, i) + 1;
        
        index = find(ms(:,i) > ms_surr(:,j,i));
        pdec(index,i) = pdec(index, i) + 1;
    end
end

pinc = (1+pinc)./(nsurr+1);
pdec = (1+pdec)./(nsurr+1);

for i=1:ncond
    sig_inc(:,i) = fdr_vector(pinc(:,i), alpha, ap.fdr_stringent);
    sig_dec(:,i) = fdr_vector(pdec(:,i), alpha, ap.fdr_stringent);
end
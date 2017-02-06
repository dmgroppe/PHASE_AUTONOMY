function [pdist, hlengths] = jphist(bursts, lengths, avglengths, ap, srate)

hlengths = ap.autocoh.prob_minburstlength:ap.autocoh.prob_bin:ap.autocoh.prob_maxburstlength*srate;
nbins = length(hlengths);
nfreqs = numel(bursts);
for i=1:nfreqs
    l = lengths{i};
    ac = [bursts{i}.is_ac];
    ind = find(ac == 0);
    l(ind) = [];
    if isempty(l) || (length(lengths{i}) < ap.autocoh.minbursts)
        pdist(i,:) = zeros(1,nbins)';
    else
        n = histc(l,hlengths);
        pdist(i,:) = n/length(lengths{i});
    end
end
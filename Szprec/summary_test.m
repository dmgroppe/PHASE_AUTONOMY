cfg = cfg_default();
[c, ia, ~] = intersect(cfg.stats.ph_tf_freqs, cfg.freqs); 
nchan = numel(spec_means);

for i=1:nchan
end
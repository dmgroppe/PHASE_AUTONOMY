function [cfg] = ampCfgDefault()

% These are the finalized analysis values for the amplitude methid of
% localizing the seizure onset zone.

cfg = cfg_default;

cfg.stats.prec_weight = 'mean';
cfg.stats.use_marked_times = 'no';  % can be 'no', 'end', 'range'
cfg.stats.freqs_to_use = 1:6;
cfg.stats.use_sig_for_rank = true;
cfg.stats.min_sig_time = 1;
cfg.stats.ampAlpha = 0.5;
cfg.stats.ampStringent = false;
cfg.stats.normalize = true;
cfg.stats.pNormPercentDiscard = .01;

% This is very important for Hilbert analysis since the values are highly
% non-normal when multiplied by the rank
cfg.stats.rank_norm = false;
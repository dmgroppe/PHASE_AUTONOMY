function [R] = Szprec_ccm_run(d, srate)

% runs CCM between two vetors, using parameters specified in cfg

cfg = cfg_default();
cfg.ccm

if cfg.ccm.dofreqs
    for i=1:size(cfg.ccm.freqs,2)
        a_cfg(i) = cfg;
        a_cfg(i).ccm.freqs = cfg.ccm.bp_freqs(:,i);
    end
    
    parfor i=1:numel(a_cfg)
        R(i) = Szprec_ccm(d, srate, a_cfg(i));
    end

else
    cfg.ccm.bp_freqs = [];
    R = Szprec_ccm(d, srate, cfg); 
end

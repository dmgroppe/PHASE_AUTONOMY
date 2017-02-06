function [R] = ccm_run(d, srate, cfg)

% runs CCM between two vectors, using parameters specified in cfg
% This additional function splits up and parellelizes the frequency analysis
% part of this.  Could have put this al in one function however

if cfg.ccm.dofreqs
    % Do different frequency bands
    for i=1:size(cfg.ccm.freqs,2)
        a_cfg(i) = cfg;
        a_cfg(i).ccm.freqs = cfg.ccm.freqs(:,i);
    end
    
    if numel(a_cfg) == 1 
        R(i) = ccm_main(d, srate, a_cfg(i));
    else
        parfor i=1:numel(a_cfg)
            R(i) = ccm_main(d, srate, a_cfg(i));
        end
    end

else
    % Do the raw time series
    cfg.ccm.bp_freqs = [];
    R = ccm_main(d, srate, cfg); 
end

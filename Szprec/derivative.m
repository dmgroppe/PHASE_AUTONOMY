function [deriv] = derivative(x, cfg, srate, f)
if cfg.diff_adaptive
    p = fix((1/(2*pi*f))*cfg.diff_adaptive_rads*srate);
    if ~p
        deriv = diff(x);
    else
        deriv = diff_n(x,p);
    end
    
else
    deriv = diff(x);
end

deriv = deriv(:);
function [csig] = get_csig(c, alpha)

stddev = imagco_stddev(c);
p = 1-normcdf(abs(c), 0, stddev);

if (length(p) == 1)
    if (p <= alpha)
        sig = 1;
    else
        sig = 0;
    end
else
    sig = FDR_corr_pop(p, alpha);
end

csig = sig.*c;
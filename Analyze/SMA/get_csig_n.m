function [csig, stddev] = get_csig_n(c, alpha, N)

stddev = sqrt(((1-c^2)*(atanh(c)^2))./(N*(N-1)*c^2));
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
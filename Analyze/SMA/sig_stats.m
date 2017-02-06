function [Sh] = sig_stats(pinc, pdec, sync, alpha, roi, doabs)

sync(32,23) = 0;

if (isempty(pdec))
    csig = FDR_corr_pop(pinc, alpha).*sync;
else
    csig = (FDR_corr_pop(pinc, alpha) + FDR_corr_pop(pdec, alpha)).*sync;
end

if (doabs)
    csig = abs(csig);
end

[R] = sort_to_regions(csig, roi);
show_region_summary(R);

Sh.in.n = R.within_num;
Sh.out.n = R.out_num;
Sh.in.var = 0;
Sh.out.var = 0;

if (R.within_num == 0 || R.out_num == 0)
    display('One of the regions has no points, stats not calculated');
    return
else
    inlist = values_from_list(csig, R.within_c);
    %inlist = [values_from_list(csig, R.within_c) values_from_list(csig, R.between_c);]
    outlist = values_from_list(csig, R.out_c);
        
    [h,p] = ttest2(inlist, outlist);
    Sh.stats.h = h;
    Sh.stats.p = p;
    Sh.in.mean =  mean(inlist);
    Sh.in.var = var(inlist);
    Sh.in.n = R.within_num;
    
    Sh.out.mean =  mean(outlist);
    Sh.out.var = var(outlist);
    Sh.out.n = R.out_num;
    
    fprintf('\nMean inside = %6.4f, stddev inside = %6.4f',mean(inlist), std(inlist));   
    fprintf('\nMean outside = %6.4f, stddev outside = %6.4f',mean(outlist), std(outlist));

    if ( h ==1 )
        fprintf('\nMeans are significantly different p =%e\n', p);
    else
        fprintf('\nMeans are NOT significantly different p =%e\n', p);
    end
end






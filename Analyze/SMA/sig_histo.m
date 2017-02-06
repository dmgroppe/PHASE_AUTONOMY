function [Sh] = sig_histo(pinc, pdec, sync, alpha, roi, doabs)

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

if (R.within_num == 0 || R.out_num == 0)
    display('One of the regions has no points, stats not calculated');
    return
else
    inlist = values_from_list(csig, R.within_c);
    outlist = values_from_list(csig, R.out_c);
    
    
    [Sh.stats.h,Sh.stats.p] = ttest2(inlist, outlist);
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





% 
% 
% siglist = csig_collect(csig);
% s_siglist = sort(siglist, 'descend');
% 
% if (length(siglist) < ntop)
%     top = s_siglist;
% else
%     top = (s_siglist(1:ntop));
% end
% 
% top_min = min(top);
%  
% % Collect all the points that above the cut off
% top_count = 0;
% for i=1:N
%     for j=i+1:N
%         if (csig(j,i) >= top_min)
%             top_count = top_count + 1;
%             top_list(:,top_count) = [j,i];
%         end
%     end
% end
% 
% % check if they are in the ROI
% in_n = 0;
% out_n = 0;
% in_list_v = [];
% out_list_v = [];
% 
% for i=1:size(top_list,2)
%     if (~isempty(find(roi == top_list(1,i), 1)) && ~isempty(find(roi == top_list(2,i), 1)))
%         in_n = in_n + 1;
%         in_list(:,in_n) = top_list(:,i);
%         in_list_v(in_n) = csig(top_list(1,i), top_list(2,i));
%     else
%         out_n = out_n + 1;
%         out_list_v(out_n) = csig(top_list(1,i), top_list(2,i));
%     end
% end
% 
% if (in_n ==0 || out_n == 0)
%     fprintf('\nIN number = %d, OUT = %d\n', in_n, out_n);
%     return;
% end
    




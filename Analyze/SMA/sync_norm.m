function [s_norm] = sync_norm(h1, h2, sync_func, nsurr, doabs)


%sync = sync_func(h1, h2);
s_norm = abs(sync_func(h1, h2));
% npoints = length(h1);
% 
% syncs = zeros(1, nsurr);
% for i=1:nsurr
%     sshift = floor(0.5*rand*npoints)+1;
%     newh(:,i) = [h2(sshift:end) h2(1:sshift-1)];
% end
% 
% parfor i=1:nsurr
%     syncs(i) = sync_func(h1, newh(:,i)');
% end
% 
% if (doabs)
%     [surr_mean,surr_std]=normfit(abs(syncs));
%     s_norm = (abs(sync)-surr_mean)/surr_std;
%     
% else
%     [surr_mean,surr_std]=normfit(syncs);
%     s_norm = (sync-surr_mean)/surr_std;
% end
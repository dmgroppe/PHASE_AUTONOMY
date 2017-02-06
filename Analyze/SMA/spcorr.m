function [r, pval] = spcorr(h1, h2, window)

nseg = nsegments(length(h1), window);
set(0,'RecursionLimit',window*2);

sync = zeros(1,nseg);
rho = sync;

index = 1:window:length(h1);
ranges = [index(1:end-1)',index(2:end)'-1];

for i=1:length(ranges)
    sstart = ranges(i,1);
    send = ranges(i,2);
    %send = sstart + wlength - 1;
    sync(i) = phase_coherence(h1(sstart:send), h2(sstart:send));
    a1 = abs(h1(sstart:send));
    a2 = abs(h2(sstart:send));
    [rho(i), ~] = corr(a1',a2','type','Spearman');
end

[r, pval] = corr(sync',rho','type','Spearman');
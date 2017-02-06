% USAGE: sync_power_corr(h1, h2, wlength, fh)
%
% Input:
%           h1, h2:     hilbert transforms of the different signals
%           wlength:    window length of the segments to compute sync over
%           fh:         function handle to syn function to use to compute
%                       sync
% Output:
%
function [R sync amps ampcorr] = sync_power_corr(h1, h2, wlength, fh, doplot)

if nargin < 5; doplot = 0; end;

nseg = nsegments(length(h1), wlength);

sync = zeros(1,nseg);
amps = zeros(2,nseg);
ampcorr = zeros(1, nseg);

index = 1:wlength:length(h1);
ranges = [index(1:end-1)',index(2:end)'-1];

A1 = abs(h1);
A2 = abs(h2);

% normalize by the std
%A1 = A1/std(A1);
%A2 = A2/std(A2);

for i=1:length(ranges)
    sstart = ranges(i,1);
    send = ranges(i,2);
    %send = sstart + wlength - 1;
    sync(i) = abs(fh(h1(sstart:send), h2(sstart:send)));
    a1 = A1(sstart:send);
    a2 = A2(sstart:send);
    amps(1,i) = mean(a1);
    amps(2,i) = mean(a2);
    [~, s, ~] = stats(a1,a2);
    ampcorr(i) = s(1);
end


[R.b(1,:), R.stats(1,:), R.yfit(1,:), R.S(1)] = stats(amps(1,:), sync);
[R.b(2,:), R.stats(2,:), R.yfit(2,:), R.S(2)] = stats(amps(2,:), sync);
[R.b(3,:), R.stats(3,:), R.yfit(3,:), R.S(3)] = stats(ampcorr, sync);


if doplot
    
    subplot(3,1,1);
    plot_sync_power(amps(1,:), sync);
    hold on;
    plot(sync, R.yfit(1,:), 'g');
    legend(sprintf('R = %6.4f, p = %6.4f', R.S(1).rho, R.S(1).pval));
    %axis([0 1 0 10]);
    axis([0 1 0 max(amps(1,:))]);
    axis square;
    
    subplot(3,1,2);
    hold on;
    plot_sync_power(amps(2,:), sync);
    plot(sync, R.yfit(2,:), 'g');
    %axis([0 1 0 10]);
    axis([0 1 0 max(amps(2,:))])
    legend(sprintf('R = %6.4f, p = %6.4f', R.S(2).rho, R.S(2).pval));
    hold off;
    axis square;
    
    subplot(3,1,3);
    hold on;
    plot_sync_power(ampcorr, sync);
    plot(sync, R.yfit(3,:), 'g');
    xlabel('Sync');
    ylabel('Amp corr');
    axis([0 1 0 1]);
    legend(sprintf('R = %6.4f, p = %6.4f', R.S(3).rho, R.S(3).pval));
    hold off;
    axis square;
end


function [] = plot_sync_power(amp, sync)

%amp = amp/max(amp);
scatter(sync, amp, '.');
xlabel('Sync');
ylabel('Amp');


function [b, stats, yfit, S] = stats(amp, sync)
X = [ones(size(sync))', sync'];
[b,~,~,~,stats] = regress(amp',X);
yfit = b(1) + b(2)*sync;

set(0,'RecursionLimit',length(amp)*2);
[S.rho, S.pval] = corr(sync',amp','type','Spearman');




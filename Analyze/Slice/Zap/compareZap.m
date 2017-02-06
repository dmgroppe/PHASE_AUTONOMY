function [R1 R2] = compareZap(r1, r2, plotZ)


if nargin < 3; plotZ = false; end;

% compare normalized Z
ap = sl_sync_params();

if iscell(r1)
    close all;R1 = zap_plot(r1,[], false);
    close all;R2 = zap_plot(r2,[], false);
    close all;
else
    R1 = r1;
    R2 = r2;
end

w_interp = R1.w_interp;
if plotZ
    y1 = nanmean(R1.mZ);
    y2 = nanmean(R2.mZ);
    y1sem = nanstd(R1.mZ)/sqrt(size(R1.mZ,1))*1.96;
    y2sem = nanstd(R2.mZ)/sqrt(size(R2.mZ,1))*1.96;
else
    y1 = R1.tnZ;
    y2 = R2.tnZ;
    y1sem = R1.tsemZ;
    y2sem = R2.tsemZ;
end


figure(1);clf;
subplot(2,1,1);
plotY(w_interp, y1, y1sem, y2, y2sem,ap)


if isfield(R1, 'name') && isfield(R2, 'name')
    legend({R1.name,R2.name});
    title(sprintf('%s(n=%d), %s(n=%d)', R1.name, numel(R1.Z), R2.name, numel(R2.Z)));
else
    legend({'cond1','cond2'});
    title(sprintf('n=%d, n=%d', numel(R1.Z), numel(R2.Z)));
end

for i=1:length(R1.w_interp)
    [p(i) h(i)] = ranksum(y1(:,i), y2(:,i));
end
axis square;
set(gca, 'TickDir', 'out');

sig = fdr_vector(p, 0.05, 0);
subplot(2,1,2);
plot(R1.w_interp, sig);
axis([R1.w_interp(1) R1.w_interp(end) ylim]);
axis square;

figure(2);clf;
bar(R1.f_centers', [R1.p_spike; R2.p_spike]', 1.5);
axis([R1.f_centers(1) R1.f_centers(end) ylim]);
axis square;
[~, pspike] = kstest2(R1.p_spike, R2.p_spike);
title(sprintf('kstest2, p = %6.2f (n1=%d, n2=%d)',pspike, numel(R1.sp_freqs_all), numel(R2.sp_freqs_all)));

set(gca, 'TickDir', 'out');



function [] = plotY(w_interp,y1, y1sem, y2, y2sem, ap)
cla
boundedline(w_interp, y1, y1sem, 'b');
hold on
boundedline(w_interp, y2, y2sem, 'g');
hold off;
set(gca, 'YScale', 'log', 'XScale', 'linear');
axis([w_interp(1) w_interp(end) ylim]);
set(gca, 'TickDir', 'out');


function [] = sync_compare_2pairs(EEG, p1, p2, cond, ap)

ap.loom_compute = 1;
ap.alpha = 0.05;

pairs(:,1) = p1;
pairs(:,2) = p2;

parfor i=1:2
    [~, ~, ~, sync(:,i), var(:,i)] = sync_freq_dependence(EEG, cond, pairs(:,i), ap);
end

sync1 = sync(:,1);
sync2 = sync(:,2);
var1 = var(:,1);
var2 = var(:,2);

% [~, ~, ~, sync1, var1] = sync_freq_dependence(EEG, cond, p1, ap);
% [~, ~, ~, sync2, var2] = sync_freq_dependence(EEG, cond, p2, ap);

N = fix(ap.length/ap.loom_window*1000);

z = (sync1-sync2)./sqrt((var1+var2)/N);
df = ((var1/N + var2/N).^2)./((var1/N).^2/(N-1) + (var2/N).^2/(N-1));
%p = 1-tcdf(abs(z),df);
p = 1-tcdf(abs(z),N);

figure(1);
ax(1) = subplot(4,1,1);
plot(ap.freqs, sync1, ap.freqs, sync2);

ax(2) = subplot(4,1,2);
plot(ap.freqs, df);

ax(3) = subplot(4,1,3);
plot(ap.freqs, p);

ax(4) = subplot(4,1,4);
[sig, pcut] = fdr_vector(p, ap.alpha);
plot(ap.freqs, sig);
fprintf('\n Pcut = %e\n', pcut);

linkaxes(ax,'xy');
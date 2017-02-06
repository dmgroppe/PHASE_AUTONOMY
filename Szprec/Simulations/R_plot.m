function [] = R_plot(r1, r2)

freqs = [r1.scfg(1).freqs];

r1_var = var(r1.nr,1);
r2_var = var(r2.nr,[],1);

m1 = mean(r1.raw,1);
m2 = mean(r2.raw,1);

figure(1); clf;
boundedline(freqs, m1, r1_var, 'b', freqs, m2, r2_var, 'r');
set(gca, 'TickDir', 'out');
axis square;

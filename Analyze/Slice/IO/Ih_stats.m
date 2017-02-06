function [P] = Ih_stats(R, alpha)

if nargin < 3; fcount = 0; end;

sig_count = 0;
P.Ih_peak = [];
P.Ih_sstateV = [];
for i=1:numel(R)
    if R(i).mp.Ih_stats ~= 0
        sig_count = sig_count + 1;
        P.Ih_peak = [P.Ih_peak  R(i).mp.Ih_peak];
        P.Ih_sstateV = [P.Ih_sstateV R(i).mp.sstate(1:length(R(i).mp.Ih_peak))];
    end
end

plot(P.Ih_sstateV, abs(P.Ih_peak), '.', 'MarkerSize', 10); 
hold on;
X = [ones(size(P.Ih_sstateV))' P.Ih_sstateV'];
[b,~,~,~,stats] = regress(P.Ih_peak', X);
xfit = min(P.Ih_sstateV):0.1: max(P.Ih_sstateV);
yfit = b(1) + b(2)*xfit;
plot(xfit, yfit, 'r');
title(sprintf('Slope = %6.4f, R2 = %6.4f, p = %6.4e', b(2), stats(1), stats(3)));
hold off;
axes_my_defaults();
axis([-150 -50 -1 20]);


% Do I_h time constant statistics

sig_count = 0;
for i=1:numel(R)
    if R(i).mp.Ih_stats ~= 0
        if R(i).mp.Ih_stats(3) < 0.05
            sig_count = sig_count + 1;
            ind = intersect(find(R(i).mp.Ih_beta(:,1) > 0),  find(R(i).mp.Ih_beta(:,5) > 0));
            mem_tau(i) = nanmedian(R(i).mp.Ih_beta(ind,1));
            Ih_tau(i) = nanmedian(R(i).mp.Ih_beta(ind,5));
        end
    end
end

display('------- Time constant statistics -----------')
mem_tau(find(mem_tau <= 0 | mem_tau > 100)) = [];
Ih_tau(find(Ih_tau <= 0 | Ih_tau > 100)) = [];
display('Membrane time constant');
display(sprintf('Mean value = %6.2f +/- %6.2f ms (N = %d)', mean(mem_tau), std(mem_tau)/length(mem_tau), length(mem_tau)));
display(sprintf('Median value = %6.2f', median(mem_tau)));

display(' ');
display('Ih time constant');
display(sprintf('Mean value = %6.2f +/- %6.2f ms (N = %d)', mean(Ih_tau), std(Ih_tau)/length(Ih_tau), length(Ih_tau)));
display(sprintf('Median value = %6.2f', median(Ih_tau)));
P.mem_tau = mem_tau;
P.Ih_tau = Ih_tau;

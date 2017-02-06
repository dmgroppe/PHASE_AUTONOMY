function [] = sl_pdpc(x, srate, ap, doplot)

if nargin < 4; ap = sl_sync_params(); end;


% d = window_highpass(1,srate, 5000);
% N = d.Numerator;
% parfor i=1:2
%     xfilt(i,:) = filtfilt(N, 1, x(i,:));
% end

xfilt = x;

wt1 = twt(xfilt(1,:), srate, linear_scale(ap.pdpc.freqs, srate), ap.pdpc.wn);
wt2 = twt(xfilt(2,:), srate, linear_scale(ap.pdpc.freqs, srate), ap.pdpc.wn);

for i=1:length(ap.pdpc.freqs)
    [~, ~, rho(i,:), p(i,:), ~, mean_phase(i)] = sync_ppc(wt1(i,:), wt2(i,:), ap.pdpc.nbins);
end

% Do the fitting
[~,c] = make_phase_bins(ap.pdpc.nbins);
[amps, pfit] = sync_ppc_amps(c, rho);
zind = find(c == 0);

pdpc_max = max(max(rho));
pdpc_min = min(min(rho));


ap.freqs = ap.pdpc.freqs;
ap.pl.ranges = 0;
ap.yaxis = [];

plap = sync_params();
plap.pl.axis = 'log';
plap.pl.colorbar = 1;


subplot(3,1,1);
plot_ppc(c, rho, ap, plap);
caxis([pdpc_min pdpc_max]);
title('Unfitted PDPC');


subplot(3,1,2);
cfit = linspace(-pi, pi, length(pfit));
plot_ppc(cfit, pfit', ap, plap);
title('Fitted PDPC');
caxis([pdpc_min pdpc_max]);


subplot(3,1,3);
plot(ap.pdpc.freqs,amps, ap.pdpc.freqs, rho(:,zind));
set(gca, 'XScale', 'log');
set(gca, 'XTickLabel', num2cell(get(gca, 'XTick')));
axis([ap.pdpc.freqs(1) ap.pdpc.freqs(end) ylim]);
legend({'PDPC - fit', 'PDPC-good phase'});

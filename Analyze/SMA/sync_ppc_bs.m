function [] = sync_ppc_bs(EEG, ch, cond, ptname)

if nargin < 5; surr = 0; end;

ap =sync_params();

[pbins,x] = make_phase_bins(ap.ppc.nbins);
% First compute the actual PPC
[rho, ~ , mean_phase] = sync_phase_power_corr_grid(EEG, ch, cond, ptname);

amps = sync_ppc_amps(x, rho);

surr_amp = zeros(length(ap.freqs), ap.nsurr);

tic
parfor i=1:ap.nsurr
    surr_amp(:,i) = surrogate_amp(EEG, ch, cond, ptname, x);
    fprintf('.');
end
toc
fprintf('\n');

counts = zeros(1,length(ap.freqs));

for i=1:length(ap.freqs)
    index = find(surr_amp(i,:) > amps(i));
    counts(i) = length(index);
end

p = (1+counts)./(ap.nsurr+1);
sig = fdr_vector(p, ap.alpha, ap.fdr_stringent);

h = figure(1);
fname = sprintf('PPC BS %s %s %d-%d', upper(ptname), upper(cond), ch(1), ch(2));
set(h,'Name', fname);
ax(1) = subplot(2,1,1);
labels.x = 'Freqs';
labels.y = 'Power correlations';
labels.title = fname;
plot_xy(ap.freqs, amps, labels, ap.yaxis);

ax(2) = subplot(2,1,2);
labels.y = 'Sig';
plot_xy(ap.freqs, sig, labels,[0 1]);

linkaxes(ax, 'x');

save_figure(h,get_export_path_SMA(), fname);

outfile = [get_export_path_SMA() fname ' SURR' '.mat'];
save(outfile, 'surr_amp', 'amps', 'ap');




function [amps] = surrogate_amp(EEG, ch, cond, ptname, pbins)

[rho, ~ , ~] = sync_phase_power_corr_grid(EEG, ch, cond, ptname,0,0,1);
amps = sync_ppc_amps(pbins, rho);
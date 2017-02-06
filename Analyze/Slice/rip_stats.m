function [] = rip_stats(avg_list, avg_freqs, acond, dosave)

% Ripple statistics using wavelet type analysis

if nargin < 4; dosave = 0; end;

lfreq_name = 'theta';
hfreq_name = 'high-gamma';

[R_supra, ~, ~, index_list] = get_mi_list(avg_list);
plap = sl_sync_params();

if numel(index_list) ~= numel(avg_list)
    display('All the files were not found');
    return;
end

daps = {R_supra(index_list).data_ap};

for i=1:numel(index_list)
    an_ap(i) = sl_sync_params();
    an_ap(i).fb.ranges(:,2) = avg_freqs(i) + [-2 2] ;
    an_ap(i).rip.lfreq = lfreq_name;
    an_ap(i).rip.hfreq = hfreq_name;
    an_ap(i).rip.cond = acond;
end

parfor i=1:numel(index_list)
    S_supra(i) = fbands_slice(daps{i}, 0, 0, an_ap(i));
end

nbins = plap.rip.bins;

all_fmaxs = [S_supra(:).fmaxs];
all_max_amp = [S_supra(:).max_amp];

[binned, xout] = hist(all_fmaxs,nbins);
[rho, p] = corr(binned', xout', 'type', 'Spearman');

findex = find_text(plap.fb.names, hfreq_name);
freqs = plap.fb.ranges(1,findex):plap.fb.ranges(2,findex);


h = figure(1);
clf;
fname = 'Ripple statistics';
set(h, 'Name', fname);
subplot(2,1,1);
hist(all_fmaxs,nbins);
axis([freqs(1) freqs(end) 0, max(binned)]);
xlabel('Frequency (Hz)');
ylabel('Counts');
set(gca, plap.pl.textprop, plap.pl.textpropval);
title(sprintf('Freq Histogram: R = %4.1e, p = %4.1e', rho, p));
axis square;

subplot(2,1,2);
plot(all_fmaxs, all_max_amp, '.b', 'LineStyle', 'None', 'MarkerSize', 5)
axis([freqs(1) freqs(end) 0 max(all_max_amp)]);
xlabel('Frequency (Hz)');
ylabel('Amplitude mV');
set(gca, plap.pl.textprop, plap.pl.textpropval);
[rho, p] = corr(all_fmaxs', all_max_amp', 'type', 'Spearman');
legend(sprintf('rho = %4.1f, p = %4.1f', rho, p));
axis square;

if dosave
    save_figure(h,export_dir_get(daps(1)), fname);
end

display(sprintf('Total number of ripple events = %d', numel(all_fmaxs)));
display(sprintf('A total of %d slices were analyzed.', numel(index_list)));



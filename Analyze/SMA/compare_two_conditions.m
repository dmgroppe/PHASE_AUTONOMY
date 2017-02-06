function [] = compare_two_conditions(EEG, cond1, cond2, frange, alpha)

[eDir] = get_export_path_SMA();

[sync(:,:,1),~] = compute_ICsync_matrix(EEG, cond1, frange, 60);
[sync(:,:,2),~] = compute_ICsync_matrix(EEG, cond2, frange, 60);

z = ic_Z(sync);
diff = z(:,:,1)-z(:,:,2);
Cdiff = iic_Z(diff);
stddev = sqrt(imagco_stddev(sync(:,:,1)).^2 + imagco_stddev(sync(:,:,2)).^2);

nchan = length(diff);

p = 1-normcdf(abs(Cdiff), 0, stddev);
sig = FDR_corr_pop(p, alpha);
csig = sig.*Cdiff;

for i=1:nchan
    for j=1:nchan
        if (isnan(csig(j,i)))
            csig(j,i) = 0;
        end
        
    end
end

h = figure(1);
text = sprintf('%s vs %s %4.0f-%4.0fHz IC Significance alpha %3.0e', upper(cond1),...
    upper(cond2), frange(1), frange(2), alpha);
set(h, 'Name', text);

plot_syncmatrix(csig, [-0.3 0.3]);
title(text);
save_figure(h, eDir, text);
%title(sprintf('%s-%s IC', cond1, cond2));

%{
figure(2);
plot_syncmatrix(get_csig(sync(:,:,1),alpha), [-0.3 0.3]);
title(text);
title(sprintf('%s IC', cond1));

figure(3);
plot_syncmatrix(get_csig(sync(:,:,2),alpha), [-0.3 0.3]);
title(text);
title(sprintf('%s IC', cond2));

chan_comb = nchan*(nchan-1)/2;
gc = zeros(3,2);
[gc(1,1), gc(1,2)] = get_csig_n(global_ic(Cdiff, 1), alpha, chan_comb);
[gc(2,1), gc(2,2)] = get_csig_n(global_ic(sync(:,:,1), 1), alpha, chan_comb);
[gc(3,1), gc(3,2)] = get_csig_n(global_ic(sync(:,:,2), 1), alpha, chan_comb);

gc

%}
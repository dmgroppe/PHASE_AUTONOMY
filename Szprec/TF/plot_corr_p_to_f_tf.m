function [h] = plot_corr_p_to_f_tf(c_mat,freqs,a_cfg,ch)

[nfreq,ncond,nchan,nsz] = size(c_mat);
[r c] = rc_plot(nchan);
cmap = flipud(cbrewer('div', 'RdYlBu', 10));

for i=1:nsz
    h(i) = figure; clf;
    %set(gcf, 'Name', sprintf('Seizure #%d', i));
    for j = 1:nchan
        subplot(r,c,j);
        plot_c = c_mat(:,:,j,i) ;
        %c_max = nanmax(nanmax(nanmax(abs(c_mat(:,:,j,:)))));
        %plot_c = plot_c/c_max;
        plot_pf(plot_c, freqs, i);
        title(sprintf('%s(%d)', ch{j}, i), 'FontSize', 6, 'FontName', 'Times');
        chan_c(:,:,j) = plot_c;
        colormap(cmap);
    end
    sz_c(:,:,:,i) = chan_c;
end

% Compute stats and average across all seizures, 

h(nsz+1) = figure; clf;
set(h(end), 'Name', 'Average across seizures');

[r c] = rc_plot(nchan+2); % One more spot for the average across all channels
for i=1:nchan
    subplot(r,c,i);
    plot_c = nanmedian(sz_c(:,:,i,:), 4);
    plot_pf(plot_c, freqs, i);
    title(sprintf('%s(%d)', ch{i},i), 'FontSize', 6, 'FontName', 'Times');
    colormap(cmap);
    
    for ci = 1: ncond
        p = [];
        for fi=1:nfreq
            v = squeeze(sz_c(fi,ci,i,:));
            p(fi) = pval(v, []);
        end
        plot_sig(p, a_cfg.stats.ph_tf_alpha, ci, nfreq);
    end
end 

% PLot thje average of seizures and channels + stats
c_stat = sz_c;
g_mean = nanmedian(nanmedian(c_stat, 4), 3);
%g_mean = g_mean/max(max(abs(g_mean)));
subplot(r,c,nchan+1)
plot_pf(g_mean, freqs, 2);
title('Average', 'FontSize', 6, 'FontName', 'Times');
colormap(cmap);
x = cell(nfreq, ncond);
for i=1:ncond
    for j=1:nfreq
        v = squeeze(c_stat(j,i,:,:));
        x{j,i} = [x{j,i} reshape(v,1,nchan*nsz)];
        p(j) = pval(x{j,i});
    end
    plot_sig(p, a_cfg.stats.ph_tf_alpha, i, nfreq);
end


% Plot the color barn
subplot(r,c,nchan+2);
for i=1:nfreq
    p(i) = pval(x{i,1}, x{i,2});
end
plot_pf(g_mean(:,2) - g_mean(:,1), freqs, 2);
plot_sig(p, a_cfg.stats.ph_tf_alpha, 1, nfreq);
colormap(cmap);
colorbar;
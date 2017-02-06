function [] = ch_cluster(pfcorr, ph_stats, ch_names)

[nfreq,ncond,nchan,nsz] = size(pfcorr);

m = nanmedian(ph_stats.ch_locs,1);
v = iqr(ph_stats.ch_locs,1);
chl = (ph_stats.ch_locs-repmat(m,nsz,1))./repmat(v,nsz,1);

k = 0;
for c=1:ncond
    for s=1:nsz
        for ch = 1:nchan
            k = k+1;
            ch_list{k} = ch_names{ch};
            %val(:,k,c) = [R.plot_values(ch) squeeze(pfcorr(:,c,ch,s))'];
            val(:,k,c) = [chl(:,ch)' squeeze(pfcorr(:,c,ch,s))'];
        end
    end
end

a = 1;
figure;clf;
[d,p,stats] = manova1(squeeze(val(:,:,1))', ch_list);
manovacluster(stats);
set(gca, 'FontSize', 5);

figure;clf;
[d,p,stats] = manova1(squeeze(val(:,:,2))', ch_list);
manovacluster(stats);
set(gca, 'FontSize', 5);

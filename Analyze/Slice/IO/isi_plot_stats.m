function [] = isi_plot_stats(stats, ap)

[ep n_isi] = size(stats);

subplot(2,1,1);
cmap = colormap(gray);
hold on;
for i=1:n_isi
    ind = find([stats(:,i).n] >=ap.io.min_isi);
    if ~isempty(ind)
        y = [stats(ind,i).m];
        ye = [stats(ind,i).std]./[stats(ind,i).n];
        if i==1
            boundedline(ind,y,ye, 'Color', [1 0 0], 'alpha');
        else
            boundedline(ind,y,ye, 'Color', cmap(i,:), 'alpha');
        end
        %errorbar(ind,y,ye, '.-', 'Color', cmap(i,:));
    end
end
hold off;
xlabel('Epoch number');
ylabel('ISI');
set(gca, 'TickDir', 'out');
set(gca,'YTick',0:10:max(ylim))

if ~isempty(ap.io.isi_axis )
    axis(ap.io.isi_axis )
end

cmap = colormap(jet);
subplot(2,1,2);
hold on;
for i=1:ep
    ind = find([stats(i,:).n] >=ap.io.min_isi);
    if ~isempty(ind)
        y = [stats(i,ind).m];
        ye = [stats(i, ind).std]./[stats(i,ind).n];
        boundedline(ind,y,ye, 'Color', cmap(4*i,:), 'alpha');
        %errorbar(ind,y,ye, '.-', 'Color', cmap(i,:));
        ltext{i} = sprintf('E %d', i);
    end
end
set(gca, 'TickDir', 'out');
legend(ltext);
xlabel('Interstim interval #');
ylabel('ISI');

if ~isempty(ap.io.isi_axis )
    axis(ap.io.isi_axis )
end
set(gca,'YTick',0:10:max(ylim))


hold off;
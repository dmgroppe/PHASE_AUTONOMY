function [] = compare_PSD(EEG, condlist, chlist, window, alpha)

srate = EEG.srate;
nchan = length(chlist);
eDir = get_export_path_SMA();

% if (length(condlist) == length(chlist))
%     fprintf('List length are not the same.');
%     return;
% end

chnum = {};
for i=1:nchan
    [tstart tend] = get_trange(condlist{i}, 60);
    tstart = tstart/1000*srate;
    tend = tend/1000*srate;
    x = EEG.data(chlist(i), tstart:tend);
    [ps(i,:),w, allps{i}] = powerspec(x,window, srate);
    chnum{i} = sprintf('%s Channel %d', condlist{i}, chlist(i));
end


h = figure(1);
set(h, 'Name', 'Power spectrum');
loglog(w,ps);
%axis equal;
plot_freq_ranges();
axis([3 srate/2 1e-4 1e4]);
legend(chnum);
save_figure(h,eDir,'Power spectrum');


if (length(chlist) == 2)
    % do pairwise comparison if only two spectra are sent in
    nfreq = length(w);
    p=zeros(1,nfreq);
    h=zeros(1,nfreq);
    ps1 = allps{1};
    ps2 = allps{2};
    
    for i=1:nfreq
        X1 = ps1(:,i);
        X2 = ps2(:,i);
        [p(i) sig(i)] = ranksum(X1,X2,'alpha', alpha);
    end
     
    h = figure(2);
    set(h, 'Name', 'Power spectrum statistics');
    ax(1) = subplot(2,1,1);
    semilogy(w,ps);
    legend(chnum);
    ax(2) = subplot(2,1,2);
    plot(w, sig);
    linkaxes(ax, 'x');
    save_figure(h,eDir,'Power spectrum - statistics');
end

function[] = plot_freq_ranges()

%rectangle('Position',[4,0.01,4,1e2], 'LineWidth',1, 'EdgeColor', 'b');
%rectangle('Position',[9,0.01,5,1e2], 'LineWidth',1, 'EdgeColor', 'b');
rectangle('Position',[23,0.01,7,1e2], 'LineWidth',1, 'EdgeColor', 'b');
rectangle('Position',[62,0.01,11,1e2], 'LineWidth',1, 'EdgeColor', 'b');
rectangle('Position',[95,0.01,12,1e2], 'LineWidth',1, 'EdgeColor', 'b');
rectangle('Position',[120,0.01,25,1e2], 'LineWidth',1, 'EdgeColor', 'b');
rectangle('Position',[6,0.01,5,1e2], 'LineWidth',1, 'EdgeColor', 'g');


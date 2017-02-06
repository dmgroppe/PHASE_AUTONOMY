function [ps,w, allps, p, sig] = ps_compare(EEG, condlist, chlist, window, ptname, alpha, doplot)


if nargin < 7; doplot = 1; end;
if nargin < 6; alpha = 0.05; end;
if nargin < 5; ptname = 'vant'; end;

srate = EEG.srate;
nchan = length(chlist);
eDir = get_export_path_SMA();
ap = sync_params();

% Each channel has an associated condition hence there can not be more
% conditions than channels.

if (numel(condlist) > numel(chlist))
    fprintf('Not enough conditions passed.');
    return;
end

chnum = {};
for i=1:nchan
    [tstart tend] = get_trange(condlist{i}, 60, ptname);
    tstart = tstart/1000*srate;
    tend = tend/1000*srate;
    x = EEG.data(chlist(i), tstart:tend);
    %x = tfilter(x, bs180);
    [ps(:,i),w, allps{i}] = powerspec(x,window, srate);
    chnum{i} = sprintf('%s Channel %d', condlist{i}, chlist(i));
end

if doplot
    h = figure(1);
    set(h, 'Name', 'Power spectrum');
    loglog(w,ps);
    %semilogy(w,ps);
    %axis equal;
    %plot_freq_ranges();
    axis([3 srate/2 1e-4 1e3]);
    legend(chnum);
    set(gca, 'TickDir', 'out');
    save_figure(h,eDir,'Power spectrum');
    xlabel('Frequency (Hz)');
    ylabel('Power \muV^2/Hz');
end


if (length(chlist) == 2)
    % do pairwise comparison if only two spectra are sent in
    nfreq = length(w);
    p=zeros(1,nfreq);
    h=zeros(1,nfreq);
    ps1 = allps{1};
    ps2 = allps{2};
    
    
    % This does a ranksum freq by frequnecy
    for i=1:nfreq
        X1 = ps1(:,i);
        X2 = ps2(:,i);
        [p(i) sig(i)] = ranksum(X1,X2,'alpha', alpha);
        pnsig(i) = sig(i)*sign(mean(X1)-mean(X2));
        
    end
    
    % FDR correct p-values and remove regions less than  a minimal
    % contiguous range
    
    [sig, pcut] = fdr_vector(p, alpha, ap.fdr_stringent);
    [~, sig] = sig_to_ranges(sig, w, ap.minr);
    
    fprintf('  Pcut = %e\n', pcut);
     
    if doplot
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
end

function[] = plot_freq_ranges()

%rectangle('Position',[4,0.01,4,1e2], 'LineWidth',1, 'EdgeColor', 'b');
%rectangle('Position',[9,0.01,5,1e2], 'LineWidth',1, 'EdgeColor', 'b');
%rectangle('Position',[7,0.01,4,1e2], 'LineWidth',1, 'EdgeColor', 'g');
%rectangle('Position',[23,0.01,10,1e2], 'LineWidth',1, 'EdgeColor', 'b');

rectangle('Position',[62,0.01,11,1e2], 'LineWidth',1, 'EdgeColor', 'b');
rectangle('Position',[95,0.01,12,1e2], 'LineWidth',1, 'EdgeColor', 'b');
rectangle('Position',[125,0.01,40,1e2], 'LineWidth',1, 'EdgeColor', 'b');
rectangle('Position',[200,0.01,200,1e2], 'LineWidth',1, 'EdgeColor', 'b');

%rectangle('Position',[53,0.01,11,1e2], 'LineWidth',1, 'EdgeColor', 'b');
%rectangle('Position',[111,0.01,16,1e2], 'LineWidth',1, 'EdgeColor', 'b');


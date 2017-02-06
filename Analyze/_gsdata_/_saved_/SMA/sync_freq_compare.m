function [mean_sync, std_sync, conflim] = sync_freq_compare(EEG, channels)

ap = sync_params();

condlist = ap.condlist;
atype = ap.atype;
usewt = ap.usewt;
freqs = ap.freqs;

ncond = size(condlist,2);

% Display some information
if ap.surr
   surrs = 'ON';
else
    surrs = 'OFF';
end
display('----------------------------------------------------------------')
fprintf('\nAnalysis = %s, Surrogates = %s', upper(ap.atype), surrs);
clist = [];
for i=1:ncond
    clist = [clist sprintf('%s ', upper(ap.condlist{i}))];
end
fprintf('\nConditions: %s', clist);

aps = ap;
% Create a surrogate list
if ncond == 2 && ~ap.surr && ap.surr2ndcond
    aps(2) = ap;
    aps(1).surr = 0;
    aps(2).surr = 1;
else
    for i=1:ncond
        aps(i) = ap;
        aps(i).surr = ap.surr;
    end
end

parfor i=1:ncond
    [mean_sync(:,i), std_sync(:,i), conflim(:,i), syncs(:,:,i)] = sync_freq_dependence(EEG, condlist{i}, channels, aps(i));
end

if ~isempty(ap.yaxis)
    sync_min = ap.yaxis(1);
    sync_max = ap.yaxis(2);   
else
    sync_max = max(max(mean_sync)) + max(max(conflim));
    sync_min = 0;
end

color_list = {'b', 'r', 'g'};

h = figure(1);
clf('reset');
figname = sprintf('%s frequency dependence', upper(atype));
set(h,'Name', figname);

if ncond == 2
    figname = [figname sprintf(' %s vs %s', upper(condlist{1}), upper(condlist{2}))];
    ax(1) = subplot(2,1,1);
    title(figname);
else
    title(figname)
end

for i=1:ncond
    if usewt
        boundedline(freqs, mean_sync(:,i), conflim(:,i), color_list{i}, 'transparency', 0.5);
        axis([freqs(1), freqs(end), sync_min, sync_max]);
    else
        boundedline(freqs(1:end-1), mean_sync(:,i), conflim(:,i), color_list{i}, 'transparency', 0.5);
        axis([freqs(1), freqs(end-1), sync_min, sync_max]);
    end
    
    if i == 1
        hold on;
    end
end

xlabel('Frequency Hz');
ylabel(upper(atype));
hold off

if ncond == 2
    ax(2) = subplot(2,1,2);
    % Ranksum to compare if means are different
    for i=1:length(ap.freqs)
        [p(i), ~] = ranksum(syncs(i,:,1), syncs(i,:,2));
    end
    subplot(2,1,2);
    
    % FDR correct
    [sig pcut] = fdr_vector(p, ap.alpha, ap.fdr_stringent);
    plot(freqs, sig);
    axis([freqs(1), freqs(end), 0, 1]);
    linkaxes(ax, 'x');
    xlabel('Frequency (Hz)');
    ylabel('Sig');

    
    % Display the cutoff for FDR and significant frequencies if any
    fprintf('\nPCUT = %e', pcut);
    if max(sig) == 0
        display('No significant frequencies.')
    else
        % Get any ranges over a specified width ap.minr
        sig_ranges = sig_to_ranges(sig, ap.freqs, ap.minr);
        if ~isempty(sig_ranges)
            fprintf('\nSignificant ranges:');
            for i=1:size(sig_ranges,2)
                fprintf('\n Range %d: %4.1f - %4.1f', i, ap.freqs(sig_ranges(1,i)),...
                    ap.freqs(sig_ranges(2,i)));
            end
        else
            fprintf('\nNo ranges of min length %4.1f', ap.minr);
        end
    end
    fprintf('\n');
   
    % Find maxima and do stats on them
    ntraces = size(syncs,2);

    for i=1:ntraces
        % Find the maxima
        ef1 = ap.freqs(localMaximum(syncs(:,i,1)));
        ef2 = ap.freqs(localMaximum(syncs(:,i,2)));
        
        for j=1:size(ap.extrema_range,2)
            % Can only have one maximum per freq range, so find if any
            eindex = find(ef1 >= ap.extrema_range(1,j) & ef1 <= ap.extrema_range(2,j));
            if isempty(eindex)
                efreqs1(j,i) = 0;
            else
                efreqs1(j,i) = ef1(eindex(1));
            end
            
            eindex = find(ef2 >= ap.extrema_range(1,j) & ef2 <= ap.extrema_range(2,j));
            if isempty(eindex)
                efreqs2(j,i) = 0;
            else
                efreqs2(j,i) = ef2(eindex(1));
            end   
        end
    end
    
    for j=1:size(ap.extrema_range,2)
        ef1 = find(efreqs1(j,:) > 0);
        ef2 = find(efreqs2(j,:) > 0);
        if ~isempty(ef1) && ~isempty(ef2)
            pstats1 = [mean(efreqs1(j,ef1)) std(efreqs1(j,ef1))/sqrt(length(ef1))];
            pstats2 = [mean(efreqs2(j,ef2)) std(efreqs2(j,ef2))/sqrt(length(ef1))];
            [p ~] = ranksum(efreqs1(j,ef1), efreqs2(j,ef2));
            fprintf('\nMaxima freq range %d - %d\n', ap.extrema_range(1,j), ap.extrema_range(2,j));
            fprintf('%s: mean = %4.0f, sem = %4.2f\n', upper(condlist{1}), pstats1(1), pstats1(2));
            fprintf('%s: mean = %4.0f, sem = %4.2f\n', upper(condlist{2}), pstats2(1), pstats2(2));
            fprintf('p = %e\n', p);
        end
    end
end

% Save it
save_figure(h, get_export_path_SMA(), figname);

% Plot the individual pairs

h = figure(2);
clf('reset');
set(h, 'Name', [figname '-individual pairs']);
npairs = size(syncs,2);
cm = colormap('lines');
linetypes = {'-', ':', '--', '-.'};
set (axes, 'FontName', 'Palatino Linotype');

for i=1:ncond
    ltcount = 1;
    cindex = 0;
    for j=1:npairs
        if cindex == 64 
            cindex = 1;
        else
            cindex = cindex + 1;
        end
        hold on;
        subplot(2,2,i);
        
        if mod(j,7) == 0
            if ltcount == 4
                ltcount = 1;
            else
                ltcount = ltcount + 1;
            end
        end
        
        plot(freqs, syncs(:,j,i), 'Color', cm(cindex,:),...
            'LineStyle', linetypes{ltcount},...
            'LineWidth', 1.5);
    end
    ylabel(upper(atype),'FontName', 'Palatino Linotype');
    xlabel('Frequency Hz','FontName', 'Palatino Linotype');
    title(condlist{i});
    if ~isempty(ap.yaxis)
        axis([freqs(1) freqs(end) ap.yaxis]);
    end
end

hold off;

if min(size(channels)) == 1
    all_pairs = pairs_all(channels);
else
    all_pairs = channels;
end

for i=1:numel(all_pairs)/2
    legend_labels{i} = sprintf('%d-%d', all_pairs(1,i), all_pairs(2,i));
end

legend(legend_labels);

save_figure(h, get_export_path_SMA(), [figname '-individual pairs']);

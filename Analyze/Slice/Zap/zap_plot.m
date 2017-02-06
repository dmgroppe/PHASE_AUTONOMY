function [S] = zap_plot(R, exportDir, doPlot)

if nargin < 3; doPlot = 1; end;
if nargin < 2; exportDir = []; end;


% Compute the average impedence for each cell.  Exclude those Z value where
% there is spiking

nCells = length(R);
sp_freqs_all = [];
spcount = 0;
handles = [];

ap = sl_sync_params();
w_interp = R{1}(1).w_interp;

count = 0;
for i=1:nCells
    if i==10
        a = 1;
    end
    if length(R{i}) >= ap.zap.min_trials
        count = count+1;
        cellInd(count) = i;
        for j = 1:length(R{i})
            if ~R{i}(j).isSpiking || ap.zap.use_spiking
                Z{count}(j,:) = R{i}(j).Z_interp;
            else
                Z{count}(j,:) = ones(1, length(R{i}(j).Z_interp)) * NaN;
            end
            sp_freqs_all = [sp_freqs_all R{i}(j).sp_freqs];
        end
    end
end

validCells = count;

for i=1:validCells
    ind = cellInd(i);
    mZ(i,:) = nanmean(Z{i});
    semZ(i,:) = nanstd(Z{i})/sqrt(size(Z{i},1));
    
    nZ = Z{i}./repmat(Z{i}(:,1)', length(w_interp), 1)';
    nmZ(i,:) = nanmean(nZ);
    nsemZ(i,:) = nanstd(nZ)/sqrt(size(Z{i},1));
end

if nCells ~= 1
    tnZ = squeeze(nanmean(nmZ));
    tsemZ = squeeze(nanstd(nmZ))/sqrt(size(Z{i},1));
else
    tnZ = nmZ;
    tsemZ = nsemZ;
end

% Do spike analysis

if ~isempty(sp_freqs_all)
    frange = ap.zap.frange(1):ap.zap.frange(end);
    nel = histc(sp_freqs_all, frange);
    f_centers = frange;
    p_spike = nel/sum(nel);
    
    spcount = numel(sp_freqs_all);
    S.spcount = spcount;
    S.fcenters = f_centers;
    S.p_spike = p_spike;
    
else
    f_centers = [];
    p_spike = [];
    
    S.fcenters = [];
    S.p_spike = [];
    S.spcount = 0;
end


S = struct_from_list('Z', Z, 'mZ', mZ, 'semZ', semZ, 'nmZ' , nmZ, 'nsemZ', nsemZ,...
    'f_centers', f_centers, 'p_spike', p_spike, 'w_interp', w_interp, 'tnZ', tnZ,'tsemZ', tsemZ,...
    'sp_freqs_all', sp_freqs_all);

%% Plot the results if specified

if doPlot
    for i=1:validCells
        h(i)=figure(i);clf;
        set(h(i),'Name', sprintf('Cell #%d', i));
        ind = cellInd(i);
        [r,c] = rc_plot(numel(R{ind})+2);
        for j=1:numel(R{ind})
            ax = subplot(r,c,j);
            loglog(R{ind}(j).w_interp, R{ind}(j).Z_interp);
            xlabel('freq(Hz)');
            ylabel('Z_norm');
            axes_text_style(ax, 10);
            axis([R{ind}(j).w_interp(1), R{ind}(j).w_interp(end), ylim]);
            if R{ind}(j).isSpiking
                title('Spiking');
            end
        end

        subplot(r,c,j+1);
        boundedline(R{ind}(j).w_interp, squeeze(mZ(i,:)), squeeze(semZ(i,:)));
         set(gca, 'YScale', 'log', 'XScale', 'log');
        xlabel('freq(Hz)');
        ylabel('avg Z');
        axes_text_style(ax, 10);
        axis([R{ind}(j).w_interp(1), R{ind}(j).w_interp(end), ylim]);


        subplot(r,c,j+2);
        set(gca, 'YScale', 'log', 'XScale', 'log');
        xlabel('freq(Hz)');
        ylabel('avg Z norm');
        axes_text_style(ax, 10);
        axis([R{ind}(j).w_interp(1), R{ind}(j).w_interp(end), [.000001 1]]);

    end

    for i=1:validCells
        fname = sprintf('Cell%d', i);
        handles = fig_handles(handles, h(i), fname);
    end


    fh = figure(length(handles)+1);
    fname = sprintf('Average %d valid cells of %d cells', validCells, nCells);
    handles = fig_handles(handles, fh, fname);

    boundedline(w_interp, tnZ, tsemZ); 
    set(h(end), 'Name', 'Grand Average');
    set(gca, 'YScale', 'log', 'XScale', 'log');
    xlabel('freq(Hz)');
    ylabel('avg Z norm');
    axis([w_interp(1), w_interp(end), ap.zap.ylim]);
    title(fname);
    axis square;

    fh = figure(length(handles)+1);
    fname = 'Spike probabilities';
    handles = fig_handles(handles, fh, fname);

    if ~isempty(f_centers)
        bar(f_centers, p_spike);
        xlabel('Frequency');
        ylabel('Spike probability');
        axis square;
        xlim([0 20]);
    end

    % Save the figures
    if ~isempty(exportDir)
        eDir = fullfile(exportDir, 'ZapAnalysis');
        if ~exist(eDir, 'dir');
            mkdir(eDir);
        end

        for i=1:length(handles)
            fname = sprintf('Cell%d', i);
            save_figure(handles(i).h, eDir, handles(i).name);
            saveas(handles(i).h,fullfile(eDir, [handles(i).name '.fig']));
        end
        %save_figure(h(end), eDir, 'Grand average');
    end
end



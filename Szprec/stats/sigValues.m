function [R] = sigValues(sz_name, doplot, savefig, a_cfg, pcfg)

% USAGE: sigValues(sz_name, doplot, savefig, pcfg)
%
% Function does a simple statistical thresholding of the log normalized F
% values, and uses these values to compute the average channel rank. 

if nargin < 2; doplot = 1; end;
if nargin < 3; savefig = 0; end;

if nargin < 4
    a_cfg = ampCfgDefault();
end

if nargin < 5
    pcfg.marker_size = 28;
    pcfg.font_size = 8;
    pcfg.font_name =  'Times New Roman';
end


R = [];
h = [];
szP = 0;
szT = 0;

pt_name = strtok(sz_name, '_');

% Load marked times files
szTimes = [];
sztFile = make_data_path(pt_name, 'sz_times');
if exist(sztFile, 'file')
    load(sztFile);
    szTimes = sz_times(find(strcmp({sz_times.name}, sz_name) == 1, 1));
    if isempty(szTimes.times)
        display(sprintf('No seizure times marked for %s', sz_name));
        szTimes = [];
    end
end

% Load the F file
fFile = make_data_path(sz_name, 'ad');
load(fFile)

% Do the appropriate average. Don't use the p_norm since it is not
% necessary to have the F values great than or equal to zero

f = fNorm(F, pt_name, a_cfg);
if a_cfg.stats.rank_norm
    fitDist = 'gamma';
else
    fitDist = 'norm';
end

% F = F(a_cfg.stats.freqs_to_use,:,:);
% switch a_cfg.stats.prec_weight 
%    case 'max'
%     f = squeeze(max(F(:,:,:),[],1));
%    case 'mean'
%     f = squeeze(mean(F(:,:,:),1));
%    case 'median'
%     f = squeeze(median(F(:,:,:),1));
% end

% Get bad channels
[~, badChannels] = bad_channels_get(pt_name);
f(:,badChannels) = 0;



% If there are seizure times marked use them as specified in a_cfg.  F
% values are truncated before doing the stats
if ~isempty(szTimes) && ~strcmpi(a_cfg.stats.use_marked_times,'no')
    szT = szTimes.times(:,1);
    szP = fix(szT*Sf);
    p = zeros(size(f));
    switch a_cfg.stats.use_marked_times
        case 'no'
            [p pcut pfit] = ampStats(f, a_cfg.stats.ampAlpha, a_cfg.stats.ampStringent, fitDist);
        case 'end'
            ind = 1:szP(2);
            fcut = f(ind,:);
            [sig pcut pfit] = ampStats(fcut, a_cfg.stats.ampAlpha, a_cfg.stats.ampStringent, fitDist);
            p(ind,:) = sig;
        case 'range'
            ind = szP(1):szP(2);
            fcut = f(ind,:);
            [sig pcut pfit] = ampStats(fcut, a_cfg.stats.ampAlpha, a_cfg.stats.ampStringent, fitDist);
            p(ind,:) = sig;
    end
else
    [p pcut pfit] = ampStats(f, a_cfg.stats.ampAlpha, a_cfg.stats.ampStringent, fitDist);
end

% Filter out those regions that are shorter than a certain minimal time.
pf = zeros(size(p));
if a_cfg.stats.min_sig_time
    for i=1:size(p,2)
%         if i == 14
%             a = 1;
%         end
        pf(:,i) = filter_p(p(:,i), a_cfg.stats.min_sig_time, Sf);
    end
else
    pf = p;
end

% Either use used the masked F values, or just significance.
if a_cfg.stats.use_sig_for_rank
    rangeAvg = mean(pf,1);
else
    rangeAvg = mean(pf.*f,1);
end

% Sort the channels
[pr,chRank] = sort(rangeAvg, 'descend');
n_ind = find(pr == 0);
chRank(n_ind) = [];

if doplot
    handles = [];
    h = figure;clf;
    fname = sprintf('%s_TF_Amplitude stats', sz_name);
    set(h, 'Name', fname);
    handles = add_fig_h(handles, h, fname);
    
    colormap(cmapMake('seq','Reds',3, 10));
    
    ax = plot2WithLabels((pf.*f)', matrix_bi, Sf, pt_name, 2);
    
    % Plot the time markers if they were used
    plotSzTime(ax(end-1), szT, a_cfg);
    linkaxes(ax,'xy');

    
    % Plot the results on the schematic
    h = figure;clf;
    fname = sprintf('%s_Schematic_Amplitude stats', sz_name);
    set(h, 'Name', fname);
    handles = add_fig_h(handles, h, fname);
    
    if ~isempty(chRank)
        if ~Szprec_schematic(pt_name)
            error('Unable to load the schematic for this patient.');
        end
        cmap = cbrewer('div', 'RdYlGn',length(chRank));

        plotElectrodesOnSchematic(pt_name,chRank, cmap, pcfg);
        title(tok_add(sz_name, '_', ' '));
    end
       
    % Plot the distribution of values and the norm fit
    h = figure; clf;
    fname = sprintf('%s_P_fit', sz_name);
    set(h, 'Name', fname);
    handles = add_fig_h(handles, h, fname);
    plotPfit(pfit);
    
    if savefig
        display('Saving figures...')
        figuresSave(handles);
    end
end

R = struct_from_list('rangeAvg', rangeAvg, 'p', p, 'pf', pf, 'chRank', chRank,...
    'a_cfg', a_cfg, 'pcut', pcut, 'pfit', pfit);

function [] = plotSzTime(ax, szT, a_cfg)
axes(ax);

if szT
    hold on;
    switch a_cfg.stats.use_marked_times
        case 'end'
            plot([szT(2) szT(2)], ylim, 'm');
        case 'range'
            for i=1:2
                plot([szT(i) szT(i)], ylim, 'm');
            end
    end
    hold off;
end

function [] = plotPfit(pfit)
bar(pfit.x,pfit.n);
hold on;
plot(pfit.x,pfit.y, 'g');
hold off
set(gca, 'TickDir', 'out', 'box', 'off');
title('P-fit')
axis square;


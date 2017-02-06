function [R avgChRank] = sigValuesSubject(pt_name, doplot, supressText)

% Plots all amp rankings for a patients and the averag

if nargin < 2; doplot = 1; end;
if nargin < 3; supressText = 0; end;

% Get the seizure list from file
sz_list = szlist(pt_name);
nsz = numel(sz_list);

% Compute the PA for each seizure
parfor i=1:nsz
    %display(sz_list{i});
    R(i) = sigValues(sz_list{i},0,0);
    rangeAvgs(:,i) = R(i).rangeAvg;
end

% Rank the average across the seizures
f = mean(rangeAvgs,2);

[fsort, avgChRank] = sort(f, 'descend');
n_ind = find(fsort == 0);
avgChRank(n_ind) = [];


% Plot everything if specified
if doplot
    h = figure;clf
    fname = sprintf('%s_Magnitude rank', pt_name);
    set(h, 'Name', fname);

    [r c] = rc_plot(nsz+1); % Additional spot for the average
    hand = tight_subplot(r,c,[.01 .01],[.1 .01],[.01 .01]);
    pcfg.marker_size = 9;
    pcfg.font_size = 3;
    pcfg.font_name =  'Times New Roman';
    
    for i=1:nsz
        %subplot(r,c,i);
        axes(hand(i));
        if ~isempty(R(i).chRank)
            Szprec_schematic(pt_name);
            cmap = cbrewer('div', 'RdYlGn',length(R(i).chRank));
            plotElectrodesOnSchematic(pt_name,R(i).chRank, cmap, pcfg);
        end
        if ~supressText
            t = sprintf('%s, p = %6.4e', tok_add(sz_list{i}, '_', ' '), R(i).pcut);
            title(t, 'FontSize', 7);
        end
        drawnow;
    end

    axes(hand(end));
    Szprec_schematic(pt_name);
    if ~isempty(avgChRank)
        cmap = cbrewer('div', 'RdYlGn',length(avgChRank));
        plotElectrodesOnSchematic(pt_name,avgChRank, cmap, pcfg);
    end
    if ~supressText
        title('Average');
    end
end

% % Do Cohen's Kappa
% 
% 
% [~, s_ind] = sort(rangeAvgs, 'descend');
% for i=1:nchan
%     for j=1:nchan
%         c(i,j) = sum(s_ind(j,:) == i);
%     end
% end
% k = kappa(c);

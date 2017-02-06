function [] = sigValuesPlot(pt_names, plotIndiv)

% Plot a list of patients, and plot their individual summaries if specifed.

if nargin < 2; plotIndiv = false; end;

npts = numel(pt_names);
pcfg = ampCfgDefault();

for i=1:npts
    display(sprintf('Computing ranks for %s...', pt_names{i}));
    [~,avgChRank{i}] = sigValuesSubject(pt_names{i}, plotIndiv);
end

if npts > 1
    [r c] = rc_plot(npts+1); % Additional spot for the average
    h = figure;clf;
    set(h, 'Name', 'SigValuesPlot');
    hand = tight_subplot(r,c,[.01 .01],[.1 .01],[.01 .01]);
    
    for i=1:npts
        axes(hand(i));

        Szprec_schematic(pt_names{i});
        if ~isempty(avgChRank{i})
            cmap = cbrewer('div', 'RdYlGn',length(avgChRank{i}));
            plotElectrodesOnSchematic(pt_names{i},avgChRank{i}, cmap, pcfg.schematic);
        end
        title(pt_names{i}, 'FontSize', 8);
    end
end




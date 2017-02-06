function rankOnSchematic(pt_name, atype, isSubPlot, pcfg)

global DATA_PATH;
global PROCESSED_DIR;

if nargin < 2; atype = 'early'; end;
if nargin < 3; isSubPlot = 0; end

if nargin < 4;
    pcfg.marker_size = 28;
    pcfg.font_size = 8;
    pcfg.font_name =  'Times New Roman';
end
    
% Get the summary statistics

summary_file = fullfile(DATA_PATH, 'Szprec', pt_name, 'Processed', PROCESSED_DIR,...
        [pt_name '_PH_Summary_' atype '.mat']);

if ~isSubPlot
    figure; clf;
end

% Plot the schematic
if ~schematicPlot(pt_name)
    display('Unable to load the schematic for this patient.');
    return;
end
    
if exist(summary_file, 'file');
    load(summary_file);
    
    [pv, r] = sort(R.plot_values);
    n_ind = find(isnan(pv) == 1);
    pv(n_ind) = [];
    r(n_ind) = [];
    if ~isempty(pv)
        cmap = cbrewer('div', 'RdYlGn',length(pv));
        plotElectrodesOnSchematic(pt_name,r, cmap, pcfg)
    end
    
    if ~isSubPlot
        fname = sprintf('%s Time ranking of channels', pt_name);
        title(fname, 'FontName', 'Times Roman', 'FontSize', 18);
        set(gcf,'Name', fname);
    end
end





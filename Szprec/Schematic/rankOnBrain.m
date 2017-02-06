function rankOnBrain(pt_name, atype, p_view, alpha, dosave)

% USAGE:    Szprec_rank_on_brain(pt_name, atype, p_view, alpha)
%
% pt_name   - two letter patient abbreviation
% atype     - 'early' typically
% p_view    - the view to plot according the plotting function
%               'lomni' - 6 views of left hemisphere
%                             'l' - Left hem lateral
%                             'lm' - Left hem medial
%                             'lo' - Left hem occipital
%                             'lf' - Left hem frontal
%                             'lim' - Left hem inferior-medial
%                             'li' - Left hem inferior
%                             'ls' - Left hem superior
%                             'lsv' - Left hem superior and vertically
%                                     aligned
%                             'liv' - Left hem inferior and vertically
%                                     aligned
% alpha     - transparency

% Best way to save this figure
%   save_figure(gcf, FIGURE_DIR, 'filename', 0, '-dtiffn', 1200, '-opengl');

global DATA_PATH;
global FIGURE_DIR;

if nargin < 2; atype = 'early'; end;
if nargin < 3; p_view = 'l'; end;
if nargin < 4; alpha = 0.5; end
if nargin <5; dosave = 0; end;

summary_file = fullfile(DATA_PATH, 'Szprec', pt_name, '\Processed\Adaptive deriv',...
        [pt_name '_PH_Summary_' atype '.mat']);
    
% Get the electrode names - they need to be identical the names in the
% FSURF text file, or they will not be plotted

[elecnames, ~] = get_channels_with_text(pt_name, [], 'mono');
nchan = length(elecnames);

% Set up the defaults
cfg = plot_3D_defaults();
cfg.opaqueness = alpha;
cfg.elecnames=elecnames;
cfg.view = p_view;
cfg.title = [];

if exist(summary_file, 'file');
    % Load the normalized times
    load(summary_file);
    
    % Sort the channels
    [pv, r] = sort(R.plot_values);
    n_ind = find(isnan(pv) == 1);
    pv(n_ind) = [];
    r(n_ind) = [];
    
    % Create the color map
    cmap = cbrewer('div', 'RdYlGn',length(pv));
    
    % Get the channel numbers for the bipolar channels
    bi_numbers = get_bi_numbers(pt_name);
   
    
    % Set the colors for the electrodes.  These are bipolar so if there is
    % overlap, the high rank is preserved for that channel
    plotted = [];
    pcolor = zeros(nchan,3);
    
    for i=1:length(pv)
        chn = bi_numbers(r(i),:);
        [~, a, ~] =  intersect(chn, plotted);
        chn(a) = [];
        for j=1:length(chn)
            pcolor(chn(j),:) = cmap(i,:);
            plotted = [plotted chn(j)];
        end
    end
    
    cfg.eleccolors = pcolor;
    
    % plot the reconstructions
    plotElecPial(pt_name, cfg);
    if dosave
        fname = sprintf('%s_time_rank_%s', pt_name, p_view);
        set(gcf, 'Name', fname);
        save_figure(gcf, FIGURE_DIR, fname, 0, '-dtiffn', 600, '-opengl');
    end
end

function [bi_numbers] = get_bi_numbers(pt_name)
global DATA_DIR;

fname = sprintf('%s_channel_info.mat', upper(pt_name));
ch_info = fullfile(DATA_DIR, 'Szprec', pt_name, fname);
load(ch_info);

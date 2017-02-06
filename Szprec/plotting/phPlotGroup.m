function [] = phPlotGroup(pt_names, dosave, atype)

% Plots final results of PH analysis on schematic for the specified
% patients.

global FIGURE_DIR;

if nargin < 3; atype = 'early'; end;
if nargin < 2; dosave = 0; end;

nPatients = numel(pt_names);

pcfg.marker_size = 9;
pcfg.font_size = 3;
pcfg.font_name =  'Times New Roman';

fh = figure; clf
fname = sprintf('PH - Group plot');
set(fh, 'Name', fname);

if nPatients == 1
    Szprec_rank_on_schematic(pt_names{1}, atype);
else
    [r c] = rc_plot(nPatients);
    h = tight_subplot(r,c,[.01 .01],[.05 .05],[.05 .05]);
    for i=1:numel(pt_names)
        axes(h(i));
        rankOnSchematic(pt_names{i}, atype, 1, pcfg);
        title(sprintf('%s',pt_names{i}), 'FontSize', 5);
    end
end

if dosave
    save_figure(fh, FIGURE_DIR, fname,0,'-dtiff', 1200);
end
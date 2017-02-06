function [] = phPlotGroup(pt_names, atype)

% Plots final results of PH analysis on schematic for the specified
% patients.

if nargin < 2; atype = 'early'; end;

nPatients = numel(pt_names);

pcfg.marker_size = 9;
pcfg.font_size = 3;
pcfg.font_name =  'Times New Roman';

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
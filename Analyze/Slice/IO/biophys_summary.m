function [] = biophys_summary(R, vals, dosave)

if nargin < 3; dosave = false; end;

global FIGURE_DIR;

[values] = biophys_collect(R, vals);

fcount = 0;
figs = [];

for i=1:numel(vals)
    fname = sprintf('Biopysical properties Summary - %s', upper(vals{i}));
    [fcount, figs] = set_figure(fcount, figs, fname);
    hist(values(:,i), 20);
    xlabel(vals{i});
    ylabel('Count');
    vstats = sprintf('Mean = %6.2f, SEM = %6.2f', mean(values(:,i)), std(values(:,i))/sqrt(numel(values(:,i))));
    title(vstats);
end

if dosave
    for i=1:fcount
        save_figure(figs(i).h, FIGURE_DIR, figs(i).name);
    end
end
function [] = plot_on_schematic(vals, analyzed_list, elist, range, sig)

d = 60;
nudge = 2;

if (isempty(range))
    vrange = max(vals)-min(vals);
    minv = min(vals);
else
    vrange = max(range) - min(range);
    minv = min(range);
end

cvals = colormap('jet');

for i=1:length(vals)
    ch = analyzed_list(i);
    cindex = fix((vals(i)-minv)/vrange * 63) + 1;
    
    if (cindex > 64)
        cindex = 64;
    end
    
    if cindex < 1;
        cindex = 1;
    end
    
    doplot = 0;
    if ~isempty(sig)
        if sig(i) ~= 0
            doplot = 1;
        end
    else
        doplot = 1;
    end
    
    if doplot
        rectangle('Position', [elist(1,ch)-d/2+nudge, elist(2,ch)-d/2+nudge, d, d],...
            'Curvature', [1 1], 'FaceColor', cvals(cindex,:), 'EdgeColor', 'none');
    end
end

delta = fix(vrange*10)/10/6;
for i=1:7
    labels{i} = sprintf('%3.2f', delta*(i-1)+floor(minv*10)/10);
end

colorbar('YTickLabel', labels);
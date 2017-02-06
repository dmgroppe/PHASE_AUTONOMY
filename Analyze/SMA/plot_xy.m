% USAGE:  plot_xy(x, y, label, yaxis)
function [] = plot_xy(x, y, label, yaxis)

plot(x, y);
xlabel(label.x);
ylabel(label.y);
title(label.title);

if ~isempty(yaxis)
    p_yaxis = yaxis;
else
    p_yaxis = [min(y) max(y)];
end
axis([x(1) x(end) p_yaxis]);
axis square;

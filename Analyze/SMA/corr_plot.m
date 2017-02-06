function [b, stats, yfit] = corr_plot(x,y,type)

if nargin <3; type = 'scatter'; end;

X = [ones(size(x))', x'];
[b,~,~,~,stats] = regress(y',X);
yfit = b(1) + b(2)*x;

switch type
    case 'scatter'
        plot(x, y, '.', 'LineStyle', 'none', 'MarkerSize', 15);
    case 'line'
        plot(x,y);
end
    
hold on
plot(x, yfit, 'g', 'LineWidth', 2);
hold off
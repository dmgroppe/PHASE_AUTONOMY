function [] = mse_stats(SE, p, roi)

Rroi = stats(SE, roi);
h = figure(1);
set(h, 'Name', 'ROI stats');
plot_mse_stats(Rroi, p, roi);




function [R] = stats(SE, roi)

R.avgs = squeeze(mean(SE(roi,:,:)));
R.stds = squeeze(std(SE(roi,:,:)));


function [] = plot_mse_stats(R, p, roi)

color_list = {'b', 'r', 'g', 'm', 'y'};
x = 1:size(R.avgs,2);
for i=1:numel(p.condlist)
    boundedline(x, R.avgs(i,:), R.stds(i,:)*1.96/sqrt(length(roi)), color_list{i}, 'transparency', 0.5);
end
axis([1 length(R.avgs) 0 2.5]);
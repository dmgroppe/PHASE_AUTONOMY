% USAGE: [sync_mean, sync_cl] = sync_dist(EEG, ap, doplot)

% Computes the synchornization across a grid and plots as a function of
% distance, with condifence limits

function [sync_mean, sync_cl] = sync_dist(EEG, ap, doplot, surr)


if nargin < 4; surr = 0; end;
if nargin < 3; doplot = 1; end

[sync,~] = analyze_SMA(EEG, ap.condlist{1}, ap.frange, ap.atype, ap.ptname, ap.length, ap.alpha, 0, surr);

% For now since I know the grid is 1-32 going to "hard" code this
nchan = 32;

count = 0;
for i=1:nchan
    [xi,yi] = get_8x8grid_xy(i);
    for j=i+1:nchan
        count = count + 1;
        [xj,yj] = get_8x8grid_xy(j);
        dist = sqrt((xi-xj)^2 + (yi-yj)^2);
        dsync(:,count) = [dist,sync(j,i)];
    end
end

udist = unique(dsync(1,:));

for i=1:length(udist)
    indicies = find(dsync(1,:) == udist(i));
    sync_mean(i) = mean(dsync(2,indicies));
    sync_cl(i) = std(dsync(2,indicies))/sqrt(length(indicies))*1.96; 
end

if doplot
    h = figure(2);
    clf('reset');
    boundedline(udist, sync_mean, sync_cl, 'b', 'transparency', 0.5);
    xlabel('Distance (cm)');
    ylabel(upper(ap.atype));
    if ~isempty(ap.yaxis)
        axis([udist(1), udist(end) ap.yaxis]);
    else
        axis([udist(1), udist(end) 0 max(sync_mean)+max(sync_cl)]);
    end
    fname = sprintf('Sync as function of distance for %s', upper(ap.atype));
    title(fname);
    save_figure(h, get_export_path_SMA(), fname);
end


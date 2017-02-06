function [] = summary_ppc(condlist, ptname, ch, dosave)

% Statisical analysis of the phase-power-correlations plots using the
% cosine fitted data to each frequency which is then used as a sample to
% perform the statistical (nonparametric) test between various condition
% and the various frquency ranges.

if nargin < 4; dosave = 0; end;

ap = sync_params();

if strcmp(ptname, 'vant')
    datadirs{1} = {'D:\Projects\Data\Vant\Figures\Super\PhasePowerCorr\Vant\'};
else
    datadirs{1} = {'D:\Projects\Data\Vant\Figures\Super\PhasePowerCorr\Nourse\'};
end

dir_names= get_dir_names(datadirs);

if isempty(dir_names)
    display('No subdirectories for this subject was found.')
    return;
end

count = 0;
for i=1:numel(dir_names)
    for j=1:numel(condlist)
        fname = sprintf('Phase-power corr %s %s %d&%d', upper(ptname), upper(condlist{j}), ch(1), ch(2));
        full_path = [cell2mat(dir_names(i)) fname '.mat'];
        if exist(full_path, 'file');
            load(full_path);
            count = count + 1;
            Res(count) = R;
        end
    end
end


% Do similar to Womdelsdorf and fit the frequency ranges to a von Mises can
% compoute the peak to trough for each frequency use that as the test
% statistic

ncond = numel(condlist);
franges = ap.extrema_range;
bins = Res(1).bins;
pbins = bins(1:end-1) + (bins(2)-bins(1))/2';
depth_index = zeros(ncond, size(franges,2));

for i=1:ncond
    for j=1:size(franges,2)
        depth_max = 0;
        index = find(ap.freqs >= franges(1,j) & ap.freqs <= franges(2,j));
        depth = [];
        for k=1:length(index)
            y = Res(i).rho(index(k), :);
            beta = nlinfit(pbins,y,@cos_fit,[0 1]);
            pfit = cos_fit(beta,pbins);
            depth(k) = max(pfit)-min(pfit);
            if depth(k) > depth_max
                depth_max = depth(k);
                depth_index(i,j) = index(k);
            end
        end
        cos_amps{j,i} = depth;
        fmeans(j,i) = mean(depth);
        fsems(j,i) = var(depth)/sqrt(length(depth));
    end
end

h = figure(2);
fname = sprintf('Summary PPC %s CH %d&%d', upper(ptname), ch(1), ch(2));
set(h, 'Name', fname);
barweb(fmeans, fsems, 1, ap.frange_names);
title(fname);
if ~isempty(ap.yaxis)
   axis([0 length(ap.frange_names)+1 ap.yaxis]);
end

if dosave
    save_figure(h, get_export_path_SMA(), fname);
end


% Do all the conmparisons
for i=1:ncond
    for j=i+1:ncond
        fprintf('\n%s vs %s', upper(condlist{i}), upper(condlist{j}));
        for k=1:size(franges,2)
            [p(k,j,i),~] = ranksum(cos_amps{k,i}, cos_amps{k,j});
            fprintf('\n Frange %d-%d: p = %6.2e', franges(1,k), franges(2,k), p(k,j,i));
        end
    end
end

% Dsiplay the frequencies for which peaks occur within the specified ranges

fprintf('\n\nPeak frequencies:')
for i=1:ncond
    fprintf(' \nCondition = %s', upper(condlist{i}))
    for j=1:size(franges,2)
        if depth_index(i,j) ~= 0
            fprintf('  \nPeak at %4.0fHz', ap.freqs(depth_index(i,j)));
        else
            fprintf('  \nNo peak at this frequency range');
        end
    end
end

for i=1:ncond
    for j=1:size(franges,2)
        depth_max = 0;
        index = find(ap.freqs >= franges(1,j) & ap.freqs <= franges(2,j));
        depth = [];
        for k=1:length(index)
            y = Res(i).rho(index(k), :);
            beta = nlinfit(pbins,y,@cos_fit,[0 1]);
            pfit = cos_fit(beta,pbins);
            depth(k) = max(pfit)-min(pfit);
            if depth(k) > depth_max
                depth_max = depth(k);
                depth_index(i,j) = index(k);
            end
        end
        cos_amps{j,i} = depth;
        fmeans(j,i) = mean(depth);
        fsems(j,i) = var(depth)/sqrt(length(depth));
    end
end

% Find global max

for i=1:ncond
    depth_max = 0;
    for k=1:length(ap.freqs)
        y = Res(i).rho(k, :);
        beta = nlinfit(pbins,y,@gauss_fit,[1 0 0]);
        pfit = gauss_fit(beta,pbins);
        depth = max(pfit)-min(pfit);
        if depth > depth_max
            depth_max = depth;
            depth_index = k;
        end
    end
    fprintf('\nGlobal maximum for %s is at %4.0f:', condlist{i}, ap.freqs(depth_index));
end

fprintf('\nDone.\n');



function [dir_names]= get_dir_names(datadirs)

count = 0;
for i=1:numel(datadirs)
    contents = dir(cell2mat(datadirs{i}));
    for j=1:numel(contents)
        if (contents(j).isdir == 1)
            if ~strcmp(contents(j).name, '.') && ~strcmp(contents(j).name, '..')
                count = count + 1;
                dir_names{count} = [cell2mat(datadirs{i}) contents(j).name, '\'];
            end
        end
    end
end
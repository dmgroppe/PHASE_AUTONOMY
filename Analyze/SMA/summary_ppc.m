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

ap.freqs = Res(1).ap.freqs;
ncond = numel(condlist);
franges = ap.extrema_range;
nfranges = size(franges,2);

% if size(franges,2) == 4
%     nfranges = 3;
% end

bins = Res(1).bins;
pbins = bins(1:end-1) + (bins(2)-bins(1))/2';
depth_index = zeros(ncond, size(franges,2));

if mod(length(pbins), ap.fitbins) ~= 0
    display('Can not reshape the matrix given fit bins');
    return;
end

beta = [1 0.5];

if ncond > numel(Res)
    display('Number of input conditions more than number of PPCs loaded');
    resp = input('Continue (y/n):', 's');
    if strcmp(resp, 'n')
        return;
    end
end

%% Compute the averages over the frequency ranges
for i=1:ncond
    fprintf('\nCondition: %s', upper(condlist{i}));
    for j=1:nfranges
        depth_max = 0;
        index = find(ap.freqs >= franges(1,j) & ap.freqs <= franges(2,j));
        depth = [];
        for k=1:length(index)
            y = Res(i).rho(index(k), :);

            y = y + min(y);
            b0 = beta;
            beta = nlinfit(pbins,y,@cos_fit,[0 1]);
            
            if beta(2) < 0
                beta(2) = 0;
            end
            
            pfit = cos_fit(beta,pbins);
            %plot(pbins,y,pbins, pfit);
            depth(k) = max(pfit)-min(pfit);
            if depth(k) > depth_max
                depth_max = depth(k);
                depth_index(i,j) = index(k);
            end
        end
        cos_amps{j,i} = depth;
        fmeans(j,i) = mean(depth);
        fsems(j,i) = var(depth)/sqrt(length(depth));
        fprintf('\n Frange %d-%d: %6.2f +- %6.2e', franges(1,j), franges(2,j), fmeans(j,i), fsems(j,i));
    end
end
fprintf('\n');

%% PLot the histograms for the each frequency range and each condition
h = figure(2);
fname = sprintf('Summary PPC %s CH %d&%d', upper(ptname), ch(1), ch(2));
set(h, 'Name', fname);
barweb(fmeans, fsems, 1, ap.frange_names);
title(fname);
if ~isempty(ap.yaxis)
   axis([0 length(ap.frange_names)+1 ap.yaxis]);
end
axis square;

if dosave
    save_figure(h, get_export_path_SMA(), fname);
end


% Do all the comparisons
for i=1:ncond
    for j=i+1:ncond
        fprintf('\n%s vs %s', upper(condlist{i}), upper(condlist{j}));
        for k=1:nfranges
            [p(k,j,i),~] = ranksum(cos_amps{k,i}, cos_amps{k,j});
            fprintf('\n Frange %d-%d: p = %6.2e', franges(1,k), franges(2,k), p(k,j,i));
        end
    end
end

save([get_export_path_SMA 'STATS.txt'], '-ascii', 'fmeans','fsems', 'p');

%% Dsiplay the frequencies for which peaks occur within the specified ranges

fprintf('\n\nPeak frequencies:')
for i=1:ncond
    fprintf(' \nCondition = %s', upper(condlist{i}))
    for j=1:nfranges
        if depth_index(i,j) ~= 0
            fprintf('  \nPeak at %4.0fHz', ap.freqs(depth_index(i,j)));
        else
            fprintf('  \nNo peak at this frequency range');
        end
    end
end

%% Find global max

for i=1:ncond
    depth_max = 0;
    for k=1:length(ap.freqs)
        y = Res(i).rho(k, :);
        beta = nlinfit(pbins,abs(y),@cos_fit,[0 1]);
        pfit = cos_fit(beta,pbins);
        %plot(pbins,y,pbins, pfit);
        depth = max(pfit)-min(pfit);
        if depth > depth_max
            depth_max = depth;
            depth_index = k;
        end
    end
    fprintf('\nGlobal maximum for %s is at %4.0f:', condlist{i}, ap.freqs(depth_index));
end

fprintf('\nDone.\n');

%% Plot the 0 phase POWER-CORR for each condition

% zindex = find(bins == 0);
% 
% if ~isempty(zindex)
%     for i=1:ncond
%         crho = ppc_sig(Res(i).rho,Res(i).p, ap);
%         yvals(:,i) = smooth(crho(:,zindex));
%     end
%     plot(ap.freqs,yvals);
%     
% else
%     display ('No zero bin to plot')
% end
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

function yhat = vm_ppc(b,X)

% b1 - amplitude of the distribution
% b2 - mean of the distribution
% b3 - kappa of the distribution

yhat = b(1)*von_mises_pdf(X,0, b(2));
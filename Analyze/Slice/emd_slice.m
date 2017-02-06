function [T, X, EMD] = emd_slice(dap, doplot, dosave, ap)

if nargin < 4
    ap = sl_sync_params;
end

if nargin < 3; dosave = 0; end;
if nargin < 2; doplot = 0; end;

[T, X] = get_cond_timeseries(dap, ap);

% Exit of there is no data
if isempty(X) || isempty (T)
    EMD = [];
    return;
end

ncond = numel(dap.cond.names);

for i=1:ncond
    %EMD{i} = emd(X{i});
    EMD{i} = eemd(X{i}, ap.emd.Nstd, ap.emd.NE);
    EMD{i}(:,1) = [];
    EMD{i} = EMD{i}';
end

if doplot
    for i=1:ncond
        h = figure(i);
        fname = sprintf('%s EMD', dap.cond.fname{1});
        set(h, 'Name', [fname '-' dap.cond.names{i}]);
        [nemd,~] = size(EMD{i});
        for j=1:nemd
            ax(j) = subplot(nemd,1,j);
            plot(T{i}+dap.cond.times(1,i), EMD{i}(j,:));
            mfreq = mean(ifreq(EMD{i}(j,:), dap.srate));
            title(sprintf('C%d - mean frequency = %6.2f', j, mfreq), ap.pl.textprop, ap.pl.textpropval);
            set(gca, ap.pl.textprop, ap.pl.textpropval);
        end
        linkaxes(ax, 'x');
        if dosave
            save_figure(h,export_dir_get(dap), [fname '-' dap.cond.names{i}]);
        end
    end
end

if dosave
    save([export_dir_get(dap) fname '.mat'], 'EMD', 'X', 'T', 'dap', 'ap');
end


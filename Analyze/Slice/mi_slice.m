function [mi phase psig X T] = mi_slice(data_ap, doplot, dosave, dop)

% Function to compute the modulation index from slice data.  Loops over
% conditions.

% Set some defaults

ap = sl_sync_params();

if nargin < 4; dop = 0; end;
if nargin < 3; dosave = 0; end;
if nargin < 2; doplot = 0; end;

% Make sure all the files exist
[fpaths, path_okay] = check_files(data_ap, '.abf');

if ~path_okay
    display(sprintf('Exiting %s.', mfilename()));
    return;
end

% Loop over the conditons and compute the MI.  The conditons may be
% different lengths

% Get the number of conditions
ncond = numel(data_ap.cond.names);

parfor i=1:ncond
    % Get the data
    [t,x, from_mat] = get_sl_data(fpaths{i}, data_ap.cond.fname{i}, data_ap.ch, ap.srate, data_ap.cond.times(:,i), ap.load_mat);
    [mi{i} phase{i} psig{i}] = sl_mi_grid(x, ap.srate, ap.mi.lfrange, ap.mi.hfrange, dop);
    phase{i} = mod(phase{i},2*pi)-pi;
    
    X{i} = x;
    T{i} = t;
end

if doplot
    h = figure(1);
    clf('reset');
    fname = sprintf('%s %s - Time series', data_ap.cond.fname{1},  upper(data_ap.chlabels{data_ap.ch}));
    set(h,'Name', fname);
    
    % Filter the data for display
    if ap.disp_filter.on
        hpf = filter_highpass(ap.disp_filter.Fc, ap.srate, ap.disp_filter.order);
        for i=1:ncond
            % Only forward filer, don't care about phase problems here
            dX{i} = filter(hpf.Numerator,1,X{i});
        end
    else
        dX{i} = X{i};
    end
    
    for i=1:ncond
        subplot(ncond,1,i);
        plot(T{i}+data_ap.cond.times(1,i),dX{i});
        axis([T{i}(1)+data_ap.cond.times(1,i), T{i}(end)+data_ap.cond.times(1,i) min(dX{i}) max(dX{i})]);
        xlabel('Time (s)');
        ylabel('mV');
        title(data_ap.cond.names{i});
    end
    
    if dosave
        save_figure(h,export_dir_get(data_ap), fname);
    end
    
    h = figure(2);
    clf('reset');
    fname = sprintf('%s %s - SYNC MI %d-%d %d-%d', data_ap.cond.fname{1},  upper(data_ap.chlabels{data_ap.ch}), ap.mi.lfrange(1),...
        ap.mi.lfrange(end), ap.mi.hfrange(1), ap.mi.hfrange(end));
    set(h, 'Name', fname);
    for i=1:ncond
        subplot(ncond,2,2*i-1);
        plot_mi(ap.mi.lfrange, ap.mi.hfrange, mi{i});
        set(gca, ap.pl.textprop, ap.pl.textpropval);
        if ~isempty(ap.mi.caxis)
            caxis(ap.mi.caxis);
        end
        title(data_ap.cond.names{i});
        
        subplot(ncond,2,2*i);
        plot_mi(ap.mi.lfrange, ap.mi.hfrange, phase{i});
        set(gca, ap.pl.textprop, ap.pl.textpropval);
        if ~isempty(ap.mi.caxis)
            caxis(ap.mi.caxis);
        end
        title(data_ap.cond.names{i});
    end
    
    if dosave
        save_figure(h,export_dir_get(data_ap), fname);
    end

    % If stats were done plot them
    if dop
        h = figure(3);
        clf('reset');
        fname = sprintf('%s %s - PSIG MI %d-%d %d-%d', data_ap.cond.fname{1},  upper(data_ap.chlabels{data_ap.ch}), ap.mi.lfrange(1),...
            ap.mi.lfrange(end), ap.mi.hfrange(1), ap.mi.hfrange(end));
        set(h, 'Name', fname);
        for i=1:ncond
            % Make sure that there significant things to plot
            subplot(ncond,1,i);
            if max(max(psig{i})) == 1
                plot_mi(ap.mi.lfrange, ap.mi.hfrange, mi{i}.*psig{i});
                set(gca, ap.pl.textprop, ap.pl.textpropval);
                title(data_ap.cond.names{i});
                if ~isempty(ap.mi.caxis)
                    caxis(ap.mi.caxis);
                end
            end

            if dosave
                save_figure(h,export_dir_get(data_ap), fname);
            end      
        end
    end
    
    % Save the data so it can be reploted
    if dosave
        fname = sprintf('%s %s - PSIG MI', data_ap.cond.fname{1},  upper(data_ap.chlabels{data_ap.ch}));
        save([export_dir_get(data_ap) fname '.mat'], 'mi', 'phase', 'psig', 'ap', 'data_ap', 'dop', 'X', 'T');
    end
end
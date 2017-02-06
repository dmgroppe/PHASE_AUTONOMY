function [w, ps, pxx] = ps_slice(data_ap, doplot, dosave)

% Function to compute power spectra from regions of an ABF file
% specified by the user.  Any number of regions can be specified in the 'ap'
% parameter structure.  Each region must have an associated label with it.


% Set some defaults

ap = sl_sync_params();

if nargin < 3; dosave = 0; end;
if nargin < 2; doplot = 0; end;

% Set default values
w = [];
ps = [];
pxx = [];

% Make sure it all the files exist
[fpaths, path_okay] = check_files(data_ap, '.abf');

if ~path_okay
    display(sprintf('Exiting %s.', mfilename()));
    return;
end

% Loop over the conditons and compute the PS.  The conditons may be
% different lengths

% Get the number of conditions
ncond = numel(data_ap.cond.names);

% Set the window size
if isempty(ap.ps.window)
    % Default to 1s window
    window = ap.srate;
else
    window = ap.ps.window;
end

for i=1:ncond
    % Get the data
    [t,x, from_mat] = get_sl_data(fpaths{i}, data_ap.cond.fname{i}, data_ap.ch, ap.srate, data_ap.cond.times(:,i), ap.load_mat);
    x = x-mean(x);
    
%     % Notch filter it
%     if ~from_mat
%         if ap.notch
%             x = harm(x,ap.notches,ap.srate, ap.bstop, ap.nharm);
%         end
%     end
    
    % Compute the power spectrum
    [ps(:,i), w, pxx{i}] = powerspec(x,window,data_ap.srate,ap.ps.usemt, ap.ps.nslep);
    
    % Save the notched data and the time (as they may be different for each
    % conditon
    
    X{i} = x;
    T{i} = t;
end

if doplot
    h = figure(1);
    clf('reset');
    fname = sprintf('%s CH#%d - Time series', data_ap.cond.fname{1}, data_ap.ch);
    set(h,'Name', fname);
    
    % Do high pass filtering for display purposes
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
        
        xlabel('Time (s)');
        ylabel('mV');
        title(data_ap.cond.names{i});
        if ~isempty(ap.raw.yaxis_range)
            axis([T{i}(1)+data_ap.cond.times(1,i) T{i}(end)+data_ap.cond.times(1,i) ap.raw.yaxis_range(1) ap.raw.yaxis_range(2)]);
        else
            axis([T{i}(1)+data_ap.cond.times(1,i), T{i}(end)+data_ap.cond.times(1,i) min(dX{i}) max(dX{i})]);
        end
    end
    
    if dosave
        save_figure(h,export_dir_get(data_ap), fname);
    end
    
    % Modify the freq axis given over_sampling etc
    faxis = w(find(w <= ap.srate/ap.over_sample));
    fend = length(faxis);
    
    
    
    % Figure 2 - Raw power spectra
    h = figure(2);  
    clf('reset');
    
    if ncond > 1
        ax(1) = subplot(2,1,1);
    end
    fname = sprintf('%s CH%d - Raw power spectra', data_ap.cond.fname{1}, data_ap.ch);
    set(h,'Name', fname);
    powerspec_plot(faxis, ps(1:fend, :), ap);
    legend(data_ap.cond.names);
    title('Raw power spectra');
    
    % If there are multiple conditions do the stats on them
    if ncond > 1
        sig = zeros(ncond,fend);
        ax(2) = subplot(2,1,2);
        for i=2:ncond
            for j=1:fend
                B = pxx{1}(:,j);
                C = pxx{i}(:,j);
                p(j) = ranksum(B,C);
            end
            sig(i-1,:) = fdr_vector(p, ap.alpha, ap.fdr_stringent);
            [~,sig(i-1,:)] = sig_to_ranges(sig(i,:), faxis, ap.minr);
        end
        semilogx(faxis,sig);
        axis([faxis(1), faxis(end) 0 1.5]);
        xlabel('Frequency (Hz)')
        ylabel('Significance');
        title(sprintf('Significance compared to %s', data_ap.cond.names{1}));
        legend(data_ap.cond.names);
        
        linkaxes(ax, 'x');
    end
    
    if dosave
        save_figure(h,export_dir_get(data_ap), fname);
    end
    
    if ncond > 1
    
        h = figure(3);
        clf('reset');
        fname = sprintf('%s CH#%d - Normalized by baseline power spectra', data_ap.cond.fname{1}, data_ap.ch);
        set(h,'Name', fname);
        
        for i=2:ncond
            pss(:,i-1) = abs(ps(:,i)./ps(:,1));
            legendtext{i-1} = sprintf('%s/%s', data_ap.cond.names{i}, data_ap.cond.names{1});
        end
        ap_ps = ap;
        ap_ps.ps.yaxis = [];
        powerspec_plot(faxis, pss(1:fend,:), ap_ps);
        
        if ~isempty(ap.ps.norm_yaxis)
            axis([faxis(1) faxis(end) ap.ps.norm_yaxis]);
        end
        legend(legendtext);
        ylabel('Normalized power');
        title('Normalized spectra');
        
        if dosave
            save_figure(h,export_dir_get(data_ap), fname);
        end
    end
end
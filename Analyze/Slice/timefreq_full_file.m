function [] = timefreq_full_file(dap, fname, dosave)

if nargin < 3; dosave = 0; end;

% Make sure the file exists
ap = sl_sync_params();

fpath = findfile(dap.Dir, [fname '.abf']);

if isempty(fpath)
    display('Unable to locate file:');
    display(sprintf('Start Dir: %s', dap.Dir));
    display(sprintf('Filename : %s', fname));
    display(sprintf('Exiting %s.', mfilename()));
    return;
end

% Load the entire file and all channels
display('Loading data...');
[S from_mat] = abf_load(fpath, fname, ap.srate, 0, 'e', ap.load_mat);
xfilt = S.data;

% The loaded file's srate may be different so set it explicitly
ap.srate = S.srate;
[nchan npoints] = size(S.data);
nfranges = numel(ap.fb.names);

% If not from matlab file then notch filter it
if from_mat
    display('Data loaded from .mat file.');
end

% If the pre-processed file did not exist save it.  Do it here in case something
% blows up afterwards
if ~from_mat
    display('Saving to matlab file in:');
    display(prep_dir_get(fpath));
    save([prep_dir_get(fpath) fname '.mat'], 'S');
end

%% Plot the actual time series
T = (0:(npoints-1))/ap.srate;  %

h = figure(10);
fig_name = sprintf('%s - Normalized time series', fname);
set(h,'Name', fig_name);

ymin = md_min(xfilt);
ymax = md_max(xfilt);

for i=1:nchan
    ax(1) = subplot(nchan,1,i);
    yplot = xfilt(i,:);
    plot(T,yplot);
    
    axis([T(1) T(end) ymin ymax]);
    if ~isempty(dap.chlabels)
        title(sprintf('Channel - %s: %s', upper(dap.chlabels{i}), get_sf_val(dap, 'Comment')));
    else
        title(sprintf('Channel #%d: %s', i , get_sf_val(dap, 'Comment')));
    end
    xlabel('Time (s)');
    ylabel('mV');
end

linkaxes(ax, 'xy');

if dosave
    save_figure(h, export_dir_get(dap), fig_name);
end

%% Band pass filter 


for i=1:nfranges
    bp(i) = window_FIR(ap.fb.ranges(1,i), ap.fb.ranges(2,i), ap.srate);
end

display('Band pass filtering within ranges...');

amps = zeros(nchan, npoints, nfranges);
sm_amps = amps;

%------------- Spectrogram -----------------------------------------------%

display('Computing wavelet transforms');
a = linear_scale(ap.wt.freqs, ap.srate);
for i=1:nchan
    wt(:,:,i) = twt(xfilt(i,:), ap.srate, a, ap.wt.wnumber);
end



%---------------- Band pass filter and compute Hilberts ------------------%

if isempty(ap.fb.sm_span)
    sm_span = 2*ap.srate;
else
    sm_span = ap.fb.sm_span;
end

parfor j=1:nfranges
    for i=1:nchan
        hs(i,:,j) = hilbert(filtfilt(bp(j).Numerator, 1, xfilt(i,:)));
    end
end


tic
%% Normalize and smooth
display('Smoothing power time series');

parfor j=1:nfranges
    for i=1:nchan
        amps(i,:,j) = abs(hs(i,:,j));
        [amps(i,:,j) sm_amps(i,:,j)] = norm_amp(amps(i,:,j), sm_span, ap.fb.sm_method);
    end
end

toc

%% Plot the fb time series
h = figure(1);
fig_name = sprintf('%s - Power time course', fname);
set(h, 'Name', fig_name)

for i=1:nchan
    ax(i) = subplot(nchan,1,i);
    dplot = squeeze(sm_amps(i,:,:));
    plot(T, dplot);
        
    % Set the axes ranges
    if ~isempty(ap.fb.yaxis)
        fb_yaxis = ap.fb.yaxis;
    else
        fb_yaxis = [md_min(dplot) md_max(dplot)];
    end

    plot_tags(dap, ap, fb_yaxis);
    axis([T(1) T(end) fb_yaxis]);
    legend(ap.fb.names);
    xlabel('Time (s)', ap.pl.textprop, ap.pl.textpropval);
    ylabel('Relative power', ap.pl.textprop, ap.pl.textpropval);
    if ~isempty(dap.chlabels)
        title(sprintf('Channel - %s: %s', upper(dap.chlabels{i}), get_sf_val(dap, 'Comment')));
    else
        title(sprintf('Channel #%d: %s', i , get_sf_val(dap, 'Comment')));
    end
    set(gca, ap.pl.textprop, ap.pl.textpropval);
    set(gca, ap.pl.axprop, ap.pl.axpropval);
end
linkaxes(ax, 'xy');

if dosave
    save_figure(h, export_dir_get(dap), fig_name);
end

% Plot the individual frequency bands
h = figure(11);
fig_name = sprintf('%s - Power time course - individual bands', fname);
set(h, 'Name', fig_name)

pcount = 0;
ax = [];
for i=1:nchan
    dplot = squeeze(sm_amps(i,:,:));
    for j=1:numel(ap.fb.names)
        pcount = pcount + 1;
        ax(pcount) = subplot(numel(ap.fb.names),nchan,i+2*(j-1));
        plot(T,dplot(:,j));
        legend(ap.fb.names{j});
        if ~isempty(ap.fb.yaxis)
            fb_yaxis = ap.fb.yaxis;
        else
            fb_yaxis = [md_min(dplot) md_max(dplot)];
        end
        plot_tags(dap, ap, fb_yaxis);
        axis([T(1) T(end) fb_yaxis]);
        xlabel('Time (s)', ap.pl.textprop, ap.pl.textpropval);
        ylabel('Relative power', ap.pl.textprop, ap.pl.textpropval);
        set(gca, ap.pl.textprop, ap.pl.textpropval);
        set(gca, ap.pl.axprop, ap.pl.axpropval);

    end
end
linkaxes(ax, 'xy');

%% FB correlations

if ap.fb.do_corr

    display('Computing frequency band correlations...');

    [tranges, Tcorr] = tlimits(ap.fb.corr_window*ap.srate/1000, length(amps), ap.srate, 0);

    corrs = zeros(nfranges, nfranges-1, length(tranges),nchan);
    p = corrs;

    for i=1:nfranges
        for j=i+1:nfranges
            for k= 1:length(tranges);
                for l = 1:nchan
                    p1 = amps(l,tranges(k,1):tranges(k,2),i)';
                    p2 = amps(l,tranges(k,1):tranges(k,2),j)';
                    [corrs(i,j,k,l), p(i,j,k,l)]  = corr(p1,p2,'type','Spearman');
                    corrs(i,j,1:2,l) = 0;
                    corrs(i,j,end-2:end,l) = 0;
                end
            end
        end
    end

    [r, c] = milti_square_plot(nfranges*(nfranges-1)/2);

    %ps = fdr_vector(p(j,k,:,i), ap.alpha, ap.fdr_stringent);
    %ps = squeeze(p(j,k,:,i)) <= ap.alpha;

    pcorr_max = -1;
    pcorr_min = 1;

    for i=1:nchan
        h = figure(2+i);
        if ~isempty(dap.chlabels)
            fig_name = sprintf('Frequency correlations - %s', upper(dap.chlabels{i}));
        else
            fig_name = sprintf('Fequency correlations - Channel #%d', i);
        end
        set(h, 'Name', fig_name);
        count = 0;
        for j= 1:nfranges
            for k = j+1:nfranges
                count = count + 1;
                ax(count) = subplot(r,c,count);
                pcorr = smooth(squeeze(corrs(j,k,:,i)),ssmooth, ap.fb.sm_method);
                pcorr_max = max([pcorr_max md_max(pcorr)]);
                pcorr_min = min([pcorr_min md_min(pcorr)]);

                plot(Tcorr,pcorr);
                xlabel('Time (s)');
                ylabel('Correlation')
                axis([Tcorr(1) Tcorr(end) pcorr_min pcorr_max]);
                title([ap.fb.names{j} ' vs ' ap.fb.names{k}]);
                set(gca, ap.pl.textprop, ap.pl.textpropval);
            end 
        end
        linkaxes(ax, 'xy');
        if dosave
            save_figure(h, export_dir_get(dap), fig_name);
        end

    end
else
    display('Skipping frequency band correlations.');
end
%% Plot the modulation indecies between different frequency bands

if ap.fb.do_mi
    
    display('Computing modulation indices...')

    [tmir, tmi] = tlimits(ap.fb.mi.span*ap.srate/1000, length(amps), ap.srate, ap.fb.mi.overlap);

    lf_ph = angle(hs);
    hf_amp = abs(hs);

    % Count the number of potential frequency pairs
    count = 0;
    for i=1:nfranges
        for j=i+1:nfranges
            if mean(mean(ap.fb.ranges(:,j)/ap.fb.ranges(:,i)) >= ap.fb.mi.limit)
                count = count + 1;
                mi_pair(:,count) = [i j];
            end
        end
    end
    
    
    % Compute the modulation index
    parfor c=1:count
        if ~ap.fb.mi.dop
            [MI(:,:,c), ~, ~] = get_mi(lf_ph,hf_amp, ap,c, mi_pair, tmir, nchan);
        else
            [MI(:,:,c), p(:,:,c), surr(:,c)] = get_mi(lf_ph,hf_amp, ap,c, mi_pair, tmir, nchan);
        end
    end

    h = figure(2+nchan+1);
    fig_name = sprintf('%s - Modulation index', fname);
    set(h, 'Name', fig_name);

    parfor i=1:count
        for j=1:nchan
            
            mi = [MI(:,j,i).tort];
            mi_ts(:,i,j) = mi;
            mi_sm(:,i,j) = smooth(mi, ap.fb.mi.sm_span, ap.fb.sm_method);
            %[mi_ts_norm(:,i,j) mi_ts_sm(:,i,j)] = norm_amp(mi,ap.fb.mi.sm_span, sm_method);
            %mi_ts(:,i,j) = [MI(:,j,i).tort];
            
            %mi_ts_norm(:,i,j) = (mi_ts(:,i,j) - mean(mi_ts(:,i,j)))/std(mi_ts(:,i,j));
            %mi_ts_sm(:,i,j) = smooth(mi_ts(:,i,j), sm_span);
        end
        labels{i} = [ap.fb.names{mi_pair(1,i)} ' - ' ap.fb.names{mi_pair(2,i)}];
    end
    
    % Select which MI to plot
    miplot = mi_sm;

    % Set the axes ranges
    if ~isempty(ap.fb.mi.yaxis)
        mi_yaxis = ap.fb.mi.yaxis;
    else
        mi_yaxis = [md_min(mi_plot) md_max(mi_plot)];
    end

    ax = [];
    for i=1:nchan
        ax(i) = subplot(nchan,1,i);
        plot(tmi,squeeze(miplot(:,:,i)));
        plot_tags(dap, ap, mi_yaxis);
        axis([tmi(1) tmi(end) mi_yaxis]);
        xlabel('Time (s)');
        ylabel('Modulation index');
        legend(labels);
        if ~isempty(dap.chlabels)
            title(sprintf('Channel - %s', upper(dap.chlabels{i})));
        else
            title(sprintf('Channel #%d', i));
        end
        set(gca, ap.pl.textprop, ap.pl.textpropval);
    end

    linkaxes(ax, 'xy');

    if dosave
        save_figure(h, export_dir_get(dap), fig_name);
    end
    
    % Plot the time course individually for figure making
    
    for i=1:nchan
        h = figure(2+nchan+1+i);
        fig_name = sprintf('%s - Modulation index CH#%d individual traces', fname, i);
        set(h, 'Name', fig_name);
        for j=1:count
            ax(j) = subplot(count,1,j);
            plot(tmi,squeeze(miplot(:,j,i)));
            plot_tags(dap, ap, mi_yaxis);
            axis([tmi(1) tmi(end) mi_yaxis]);
            legend(labels{j});
            set(gca, ap.pl.textprop, ap.pl.textpropval);
        end
        
        linkaxes(ax,'xy');
        
        if dosave
            save_figure(h, export_dir_get(dap), fig_name);
        end
    end
    
else
    display('Skipping modulation indices.');
end

% % Save the entire workspace for later replotting
% if dosave
%     % Check to see if there is a pre_processed DIR, if so save there,
%     % otherwise go to ExportDir
%     [user_prepdir] = user_data_get('prepdir');
%     if isempty(user_prepdir)
%         ed = export_dir_get(dap);
%     else
%         ed = user_prepdir;
%     end
%     save([ed fname '_TFFF.mat']);
%     display('Workspace saved to:');
%     display([ed fname '_TFFF.mat']);
% end



%% Phase coherence between different layers


function [MI p surr_mi] = get_mi(lf_ph, hf_amp, ap,c, mi_pair, tmir, nchan)

% MI = [];
p = [];
surr_mi = [];

for k = 1:length(tmir)
    for l=1:nchan
        ij = mi_pair(:,c);
        i = ij(1);
        j = ij(2);
        
        if ap.fb.mi.dop
            [MI(k,l), p(k,l), surr_mi(:,k,l)] = sync_mi(lf_ph(l,tmir(k,1):tmir(k,2),i), hf_amp(hs(l,tmir(k,1):tmir(k,2),j)),...
                ap.fb.mi.nbins, ap.fb.mi.nsurr, ap.fb.mi.dop, ap);
        else
            [MI(k,l), ~, ~] = sync_mi(lf_ph(l,tmir(k,1):tmir(k,2),i), hf_amp(l,tmir(k,1):tmir(k,2),j), ...
                ap.fb.mi.nbins, ap.fb.mi.nsurr, ap.fb.mi.dop, ap);
        end

    end
end

function [amps sm_amps] = norm_amp(amps, sm_span, sm_method)
    % Effectively a Z-score using a specified baseline
amps = (amps-mean(amps))/std(amps);

% Smooth the data for display
sm_amps = smooth(amps, sm_span, sm_method);


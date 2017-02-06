function [] = rp_timefreq_full_file(dap, fname, dosave)


[user_prepdir] = user_data_get('prepdir');
if isempty(user_prepdir)
    ed = export_dir_get(dap);
else
    ed = user_prepdir;
end

if ~exist([ed fname '_TFFF.mat'], 'file')
    display('The specified workspace does not exist')
    return;
end

display('Loading workspace...');
load([ed fname '_TFFF.mat']);

% Reload ap since you want the new paramaters not the old ones
ap =sl_sync_params();

display('Resmoothing the data...');

if isempty(ap.fb.sm_span)
    sm_span = 2*ap.srate;
else
    sm_span = ap.fb.sm_span;
end

amps = zeros(1,1,1);
parfor j=1:nfranges
    for i=1:nchan
        %amps(i,:,j) = abs(hs(i,:,j));
        
        % Compute a Z-score over the full data
        %amps(i,:,j) = (amps(i,:,j)-mean(amps(i,:,j)))/std(amps(i,:,j));
        
        % Smooth the data for display
        sm_amps(i,:,j) = smooth(amps(i,:,j), sm_span, ap.fb.sm_method);
    end
end

% Replot the power time course

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




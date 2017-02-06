function [x T wt ap dap] = sl_spectrogram(dap, fname, dosave)

user = user_get();

full_file = [char(user.prep.dir) fname '_wt.mat'];
if exist(full_file, 'file');
    display('Loading pre-processed wavelet transform');
    load(full_file);
else
    display('Pre-processed data not found loading raw data...');
    ap = sl_sync_params();
    S = load_dap(dap, ap, fname);
    [nchan npoints] = size(S.data);

    x = S.data;
    
    % Copy over some params to the dap
    dap.srate = S.srate;
    dap.wt.freqs = ap.wt.freqs;
    dap.wt.wnumber = ap.wt.wnumber;
    
    T = (0:(npoints-1))/dap.srate;

    display('Computing wavelet transforms...');
    a = linear_scale(ap.wt.freqs, dap.srate);
    for i=1:nchan
        wt(:,:,i) = twt(x(i,:), dap.srate, a, ap.wt.wnumber);
    end
    display('Saving wavelet transform...')
    save(full_file, '-v7.3', 'wt','x','T','dap', 'ap');
end

% Check to see if 'wt' was save, since sometimes they were not.
if ~exist('wt', 'var')
    display('The wavelet transform was not saved for this file...');
    display(full_file);
    wt = [];
    return;
else
    sp_ap = sl_sync_params();
    h = figure(1);
    fig_name = sprintf('%s - Spectrogram', fname);
    set(h,'Name', fig_name);
    plot_spectrogram(wt, x, T, ap, sp_ap.spec.dec, sp_ap.spec.trange, sp_ap.spec.markers);
    if dosave
        save_figure(h, user.ExportDir, fig_name, false);
    end
end


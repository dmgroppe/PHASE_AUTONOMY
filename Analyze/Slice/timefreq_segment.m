function [] = timefreq_segment(dap, fname, trange, doplot, dosave)

if nargin < 3; dosave = 0; end;

% Make sure the file exists
ap = sl_sync_params();

fpath = check_file(dap, fname, '.abf');

if isempty(fpath)
    return;
end

% Load the entire file and all channels
display('Loading data...');
[S from_mat] = abf_load(fpath, fname, ap.srate, trange(1), trange(2), ap.load_mat);

% The loaded file's srate may be different so set it explicitly
ap.srate = S.srate;
[nchan npoints] = size(S.data);
[scales, freqs] = wt_scales(ap);
T = (0:(npoints-1))/ap.srate + trange(1); % Time in seconds

snorm = repmat(scales',1, npoints);

display('Computing wavelet transforms...')
for i=1:nchan
    wt(:,:,i) = twt(S.data(i,:), ap.srate, scales, ap.wt.wnumber);
    a = abs(wt(:,:,i));
    sgram(:,:,i) = log10(a./snorm);
    %z(:,:,i) = (a-repmat(mean(a,2),1,npoints))./repmat(std(a,1,2),1,npoints);
end

to_plot = sgram;

for i=1:nchan
    figure(i);
    ax(1) = subplot(2,1,1);
    set(gcf,'Renderer', 'zbuffer');
    surf(T, freqs, to_plot(:,:,i));
    axis([T(1) T(end) freqs(1) freqs(end) md_min(to_plot(:,:,i)) md_max(to_plot(:,:,i))]);
    view(0,90);
    shading interp;
    colormap jet;
   
    set(gca, ap.pl.textprop, ap.pl.textpropval);
    if ~isempty(dap.chlabels)
        title(sprintf('Channel - %s', upper(dap.chlabels{i})));
    else
        title(sprintf('Channel #%d', i));
    end
    
    ax(2) = subplot(2,1,2);
    plot(T,S.data(i,:));
    axis([T(1) T(end) min(S.data(i,:)) max(S.data(i,:))]);
    xlabel('Time (s)');
    ylabel('mV');
    set(gca, ap.pl.textprop, ap.pl.textpropval);
    
    linkaxes(ax, 'x');
end



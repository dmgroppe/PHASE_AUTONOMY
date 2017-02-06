function [Z] = plot_spectrogram(wt, xfilt, T, dap, dec, trange, markers)

if nargin < 7; markers = []; end;
if nargin < 6; trange = []; end;
if nargin < 5; dec = 1; end;

ap = sl_sync_params();

% Truncate the WT transients at the extremes
trunc = fix(ap.spec.ncycles/min(dap.wt.freqs)*dap.srate);
if (2*trunc >= length(wt))
    error('Data segment too short for desired frequencies');
end
wt = wt(:,trunc:end-trunc,:);
x = xfilt(:,trunc:end-trunc);

amp = abs(wt);

amean = squeeze(mean(amp,2));
astd = squeeze(std(amp,1,2));

[nfreq npoints, nchan] = size(wt);

for i=1:nchan
    Z(:,:,i) = (amp(:,:,i)-repmat(amean(:,i),1,npoints))./(repmat(astd(:,i),1,npoints));
end

% Truncate the wt transients at the end;

t = T(trunc:end-trunc);
% Times to plot in seconds
%dec = 1;

if isempty(trange)
    trange = [t(1) t(end)];
    dec = 100;
end

%trange = [t(1) t(end)];
%trange = [ 904  914];
%trange = [ 877  917];
%trange = [908 909];
%trange = [908 909];
%trange = [432.2206  526.7827];

ind = find(t>=trange(1) & t<= trange(2));

if isempty(ind)
    error('trange is out of bounds');
end
di = ind(1):dec:ind(end);

count = 0;
set(gcf, 'Renderer', 'zbuffer');

% Plot vertical lines that demarcate things
%markers = [908 909];

for i=1:nchan

    tplot = t(di);
    zplot = Z(:,di,i);
    xplot = x(i,di);
    xplot = xplot-mean(xplot);
    
    count = count + 1;
    ax(count) = subplot(2*nchan,1,count);
    plot(tplot,xplot);
    axis([min(tplot) max(tplot) min(xplot) max(xplot)]);
    
    % plot the markers;
    hold on;
    for j=1:length(markers)
        plot([markers(j) markers(j)], [min(xplot) max(xplot)], 'r');
    end
    hold off;
    set(gca, ap.pl.textprop, ap.pl.textpropval, 'TickDir', 'out');
    ylabel('mV');
    xlabel('Time (s)');
    
    if ~isempty(dap.chlabels)
        title(sprintf('Channel - %s: %s', upper(dap.chlabels{i}), get_sf_val(dap, 'Comment')));
    else
        title(sprintf('Channel #%d: %s', i , get_sf_val(dap, 'Comment')));
    end
       
    count = count + 1;
    ax(count) = subplot(2*nchan,1,count);
    surf(tplot,dap.wt.freqs, zplot);
    axis([min(tplot) max(tplot) ap.wt.freqs(1) ap.wt.freqs(end) min(min(zplot)) max(max(zplot))]);
    set(gca, 'YScale', 'log', 'YMinorTick', 'on', 'TickDir', 'out');
    yvals = get(gca,'YTickLabel');
    set(gca,'YTickLabel',  10.^str2num(yvals));
    caxis(ap.spec.zcaxis);
    shading interp;
    view(0,90);
    set(gca, ap.pl.textprop, ap.pl.textpropval);
    ylabel('Z-score');
    xlabel('Time (s)');
end

linkaxes(ax, 'x');
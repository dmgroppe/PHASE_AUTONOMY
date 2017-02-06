function [Z] = plot_sync(pc, phi, wt, xfilt, T, dap, dec, trange, markers)

if nargin < 7; markers = []; end;
if nargin < 6; trange = []; end;
if nargin < 5; dec = 1; end;

ap = sl_sync_params();

% Truncate the WT transients at the extremes
trunc = fix(ap.spec.ncycles/min(dap.wt.freqs)*dap.srate);
if (2*trunc >= length(wt))
    error('Data segment too short for desired frequencies');
end

% Cut them to the same length
pc_length = length(pc);

if length(wt)-length(pc) > trunc
    wt = wt(:,trunc:pc_length,:);
    pc = pc(:,trunc:end);
    t = T(trunc:pc_length);
else
    wt = wt(:,trunc:end-trunc,:);
    pc = pc(:,trunc:end-(length(wt)-pc_length));
    t = T(trunc:end-trunc);
end

amp = abs(wt);

amean = squeeze(mean(amp,2));
astd = squeeze(std(amp,1,2));

[nfreq npoints, nchan] = size(wt);

for i=1:nchan
    Z(:,:,i) = (amp(:,:,i)-repmat(amean(:,i),1,npoints))./(repmat(astd(:,i),1,npoints));
end

if isempty(trange)
    trange = [t(1) t(end)];
    dec = 100;
end

ind = find(t>=trange(1) & t<= trange(2));

if isempty(ind)
    error('trange is out of bounds');
end

% Get the indices to plt
di = ind(1):dec:ind(end);

count = 0;
set(gcf, 'Renderer', 'zbuffer');


if isempty(phi)
    nplots = 2*nchan+1;
else
    nplots = 2*nchan+2;
end

for i=1:nchan

    tplot = t(di);
    zplot = Z(:,di,i);
    xplot = xfilt(i,di);
    xplot = xplot-mean(xplot);
    
    count = count + 1;
    ax(count) = subplot(nplots,1,count);
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
    ax(count) = subplot(nplots,1,count);
    surf(tplot,ap.wt.freqs, zplot);
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

% PLot the phase-coherence values
count = count + 1;
pc_mean = mean(pc,2);
std_pc = std(pc,1, 2);
zpc = (pc -repmat(pc_mean,1, length(pc)))./repmat(std_pc, 1, length(pc));
tplot = t(di);

pc_plot = zpc(:,di);
ax(count) = subplot(nplots,1,count);
surf(tplot,ap.wt.freqs, pc_plot);
axis([min(tplot) max(tplot) ap.wt.freqs(1) ap.wt.freqs(end) min(min(pc_plot)) max(max(pc_plot))]);
set(gca, 'YScale', 'log', 'YMinorTick', 'on', 'TickDir', 'out');
yvals = get(gca,'YTickLabel');
set(gca,'YTickLabel',  10.^str2num(yvals));
caxis([-2 2]);
shading interp;
view(0,90);
set(gca, ap.pl.textprop, ap.pl.textpropval);
ylabel('PC Z-score');
xlabel('Time (s)');

% Plot the phase differences
count = count + 1;
ax(count) = subplot(nplots,1,count);
surf(tplot,ap.wt.freqs, phi(:,di));
axis([min(tplot) max(tplot) ap.wt.freqs(1) ap.wt.freqs(end) -pi pi]);
set(gca, 'YScale', 'log', 'YMinorTick', 'on', 'TickDir', 'out');
yvals = get(gca,'YTickLabel');
set(gca,'YTickLabel',  10.^str2num(yvals));
caxis([-pi pi]);
shading interp;
view(0,90);
set(gca, ap.pl.textprop, ap.pl.textpropval);
ylabel('Phase difference');
xlabel('Time (s)');
title('Phase difference CH1-Ch2')

linkaxes(ax, 'x');
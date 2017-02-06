function [amp intervals] = sync_power_freq_corr(EEG, ch, cond, ptname, frange, doplot, dosave)

% This returns a list of inter-event intervals as as a fucntion of the size of
% the preceeding amplitude fluctuation as described by Attalh et al, 2009.

if nargin < 7; doplot = 0; end
if nargin < 6; dosave = 0; end;

if dosave
    doplot = 1;
end

% Save the analysis info in AP
ap = sync_params();
ap.condlist{1} = cond;
ap.ptname = ptname;
ap.chlist = ch;
nbins = 20;

% Get the data
[tstart tend] = get_trange(cond, ap.length, ptname);
subr = get_subregion(EEG, tstart, tend);
subr = subr(ch,:);

d = window_FIR(frange(1), frange(2), EEG.srate);
x = filtfilt(d.Numerator,1,subr);

maxims = local_max(x);
maxims = maxims(2:end-1);
t = (0:length(x)-1)/EEG.srate;

% Get the previous amplitude and the following interval
for i=1:length(maxims)-1
    ie = maxims(i):maxims(i+1);
    amp(i) = x(ie(1))- min(x(ie));
    intervals(i) = ie(end)-ie(1);
end

% Reverse the relationship
if ap.fpc.revrel
    intervals = intervals(2:end);
    amp = amp(1:end-1);
end

if doplot

    figure(1);
    plot(t,x);

    hold on;
    tm =  (maxims-1)/EEG.srate;
    plot(tm,x(maxims),'.r','LineStyle', 'none', 'MarkerSize',5);
    hold off;

    fname = sprintf('FPC %s %s CH %d %d-%dHz HISTO', upper(ptname), upper(cond), ch, frange(1), frange(2));
    h = figure(2);
    set(h, 'Name', fname);
    subplot(2,1,1);
    hist(amp,nbins);
    xlabel('uV');
    ylabel('Counts');
    axis square;

    subplot(2,1,2);
    hist(intervals/EEG.srate*1000,nbins);
    xlabel('Interval');
    ylabel('Counts');
    axis square;

    
    if dosave
        save_figure(h, get_export_path_SMA(), fname);
    end

    freqs = (1./(intervals/EEG.srate));
    tintervals = intervals/EEG.srate*1000;

    figure(3);
    plot(amp, tintervals, '.b', 'LineStyle', 'none', 'MarkerSize',5);
    axis([0, max(amp) 0 max(tintervals)]);
    xlabel('Amplitude (uV)');
    ylabel('Intervals (ms)');

    [rho, p] = corr(amp',tintervals','type','Spearman');
    ltext = sprintf('R = %4.2f, p = %e', rho,p);
    legend(ltext);
end





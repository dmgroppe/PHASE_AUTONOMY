function [R] = fbands_slice(data_ap, doplot, dosave, ap)

% Function to band pass filter the series into user defined frequency bands
% and do some rudimentary analyses on them.  Currently a ripple analyses is
% contained within this funciton but will be likely made into a stand alone
% function.

if nargin < 4
    ap = sl_sync_params;
end

if nargin < 3; dosave = 0; end;
if nargin < 2; doplot = 0; end;

[T, X] = get_cond_timeseries(data_ap, ap);

% Exit of there is no data
if isempty(X) || isempty (T)
    return;
end

ncond = numel(data_ap.cond.names);

Xfilt = filter_conds(X, ap);
[~,nbands] = size(ap.fb.ranges);

% Filter the data
hpf = filter_highpass(ap.disp_filter.Fc, ap.srate, ap.disp_filter.order);
for i=1:ncond
    if ap.disp_filter.on
        dX{i} = filtfilt(hpf.Numerator,1,X{i});
    else
        dX{i} = X{i};
    end
end

% Plot the filtered time series
if doplot
    for i=1:ncond
        h = figure(i);
        clf;
        fname = sprintf('FBANDS %s- %s', data_ap.cond.fname{1}, data_ap.cond.names{i});
        set(h, 'Name', fname);
        ax(1) = subplot(nbands+1,1,1);
        plot(T{i}+data_ap.cond.times(1,i),dX{i});
        set(gca, ap.pl.textprop, ap.pl.textpropval);
        title('Raw data');
        ylabel('mV');
        xlabel('Time (s)');

        if ~isempty(ap.raw.yaxis_range)
            axis([T{i}(1)+data_ap.cond.times(1,i) T{i}(end)+data_ap.cond.times(1,i) ap.raw.yaxis_range(1) ap.raw.yaxis_range(2)]);
        else
            axis([T{i}(1)+data_ap.cond.times(1,i), T{i}(end)+data_ap.cond.times(1,i) min(X{i}) max(X{i})]);
        end
        for j = 1:nbands
            ax(j+1) = subplot(nbands+1,1,j+1);
            plot(T{i}+data_ap.cond.times(1,i),Xfilt{i}(:,j));
            title(sprintf('%s - %d-%dHz' ,upper(ap.fb.names{j}), ap.fb.ranges(1,j), ap.fb.ranges(2,j)));
            set(gca, ap.pl.textprop, ap.pl.textpropval);
            if ~isempty(ap.raw.yaxis_range)
                axis([T{i}(1)+data_ap.cond.times(1,i) T{i}(end)+data_ap.cond.times(1,i) ap.raw.yaxis_range(1) ap.raw.yaxis_range(2)]);
            else
                axis([T{i}(1)+data_ap.cond.times(1,i), T{i}(end)+data_ap.cond.times(1,i) min(Xfilt{i}(:,j)) max(Xfilt{i}(:,j))]);
            end

        end
        linkaxes(ax, 'xy');
    end

    if dosave
        save_figure(h,export_dir_get(data_ap), fname);
    end
end

%% 'Ripple' amplitude and frequency variablity analysis
% Now take the high-gamma range and do a wavelet spectrum in it to see the
% variability in frequency

hfreq_name = ap.rip.hfreq;
% Freq index
findex = find_text(ap.fb.names, hfreq_name);

% Cond index
cindex = find_text(data_ap.cond.names, ap.rip.cond);
if ~cindex
    display(sprintf('%s condition does not exist for this slice.', ap.rip.cond));
    return;
end

freqs = ap.fb.ranges(1,findex):ap.fb.ranges(2,findex);

% Get the time range, WTs, envelopes etc
high_y = Xfilt{cindex}(:,findex);
X = T{cindex}+data_ap.cond.times(1,cindex);
wt = twt(high_y, ap.srate, linear_scale(freqs,ap.srate),ap.rip.wnumber);

if ap.rip.use_power
    amp = abs(wt).^2;
else
    amp = abs(wt);
end
env = abs(hilbert(high_y));

% Get the local maxima, using a few criteria.  300 is period between
% sucessive theta oscillations

I = localMaximum(env, ap.rip.mindist, true);
% Determine the cutoff
acut = ap.rip.sd*std(env);
Icut = find(env(I) >= acut);

% Get the indicies of the maxima that are above the cutoff
max_ind = I(Icut);

% Get the max amplitudes for where the maxima are, and the frequncies at
% which they occur


max_amp = max(amp(:,max_ind));
for i=1:length(max_ind)
    fmaxs(i) = freqs(find(amp(:,max_ind(i)) == max_amp(i)));
end

% Instead of using the power/amplitude of the wave use the height of the
% ripple
if ~ap.rip.wt_amp
    max_amp = env(max_ind)';
end

R.max_amp = max_amp;
R.fmaxs = fmaxs;

% If there is a low freq specified do the calculations here
if ~isempty(ap.rip.lfreq)
    findex = find_text(ap.fb.names, ap.rip.lfreq);
    low_y = Xfilt{cindex}(:,findex);
    lphase = angle(hilbert(low_y));
    phases = phase_diff(lphase(max_ind));
    R.phases = phases;
    
    mean_angle = fix(circ_rad2ang(circ_mean(phases)));
    if mean_angle < 0
        mean_angle = 360+mean_angle;
    end
else
    R.phases = [];
end

if doplot

    h = figure(ncond + 1);
    clf;
    fname = sprintf('FBANDS TF %s - %s', data_ap.cond.fname{1}, hfreq_name);
    set(h, 'Name', fname);
    if ~isempty(ap.rip.lfreq)
        nplots = 3;
    else
        nplots = 2;
    end

    set(gcf, 'Renderer', 'zbuffer');
    ax(1) = subplot(nplots,1,1);
    
    if ~isempty(ap.rip.taxis)
        pind = find(X >= ap.rip.taxis(1) & X <= ap.rip.taxis(2));
        Xplot = X(pind);
        
    else
        Xplot = X;
        pind =1:numel(X);
    end

    Z = amp(:,pind);
    surf(Xplot, freqs, Z);
    axis([Xplot(1) Xplot(end) freqs(1) freqs(end) min(min(Z)) max(max(Z))]);
    caxis([min(min(Z)) max(max(Z))]);
    shading interp;
    view(0,90);

    ax(2) = subplot(nplots,1,2);
    plot(Xplot,high_y(pind));
    axis([Xplot(1) Xplot(end) min(min(high_y(pind))) max(max(high_y(pind)))]);

    % Get the envelope
    hold on;
    plot(Xplot,env(pind), 'g');
    axis([Xplot(1) Xplot(end) min(min(high_y(pind))) max(max(high_y(pind)))]);
    hold off

    % Plot the maxima 
    hold on;
    
    pmax_ind = intersect(pind, max_ind);
    plot(X(pmax_ind),env(pmax_ind), '.r', 'LineStyle', 'None');
    axis([X(pmax_ind(1)) X(pmax_ind(end)) min(min(high_y)) max(max(high_y))]);
    hold off;

    % Plot the low frequency waveform;
    if ~isempty(ap.rip.lfreq)
        ax(3) = subplot(nplots,1,nplots);
        plot(Xplot,low_y(pind));
        axis([Xplot(1) Xplot(end) min(min(low_y(pind))) max(max(low_y(pind)))]);
    end

    linkaxes(ax, 'x');

    if dosave
        save_figure(h,export_dir_get(data_ap), fname, false);
    end
    
%     cla(ax(1));
%     if dosave
%         save_figure(h,export_dir_get(data_ap), [fname ' NO TF']);
%     end
    

    %% Stats on the frequency information
    % Now that I have the indices for the maxima of the highfrequncy component
    % do some stats on them


    if ~isempty(ap.rip.lfreq)
        nplots = 3;
    else
        nplots = 2;
    end

    % Plot the  frequency histogram
    h = figure(ncond + 2);
    clf;
    fname = sprintf('FBANDS STATS %s - %s', data_ap.cond.fname{1}, hfreq_name);
    set(h, 'Name', fname);

    subplot(nplots,1,1);
    N = hist(fmaxs,10);
    hist(fmaxs,10);
    xlabel('Frequency (Hz)')
    axis square;
    axis([min(fmaxs) max(fmaxs) 0 max(N)]);
    set(gca, ap.pl.textprop, ap.pl.textpropval);

    subplot(nplots,1,2);
    plot(fmaxs, max_amp, 'b.', 'LineStyle', 'None', 'MarkerSize', 5);
    axis([min(fmaxs) max(fmaxs) 0 max(max_amp)]);
    xlabel('Frequency Hz');
    ylabel('Amplitide');
    [rho, p] = corr(fmaxs', max_amp', 'type', 'Spearman');
    legend(sprintf('rho = %4.1f, p = %4.1f', rho, p));
    axis square;
    set(gca, ap.pl.textprop, ap.pl.textpropval);
    
  
    % Plot the phase angle distribution of then the maxima occur for the low
        % frequency phase
    if ~isempty(ap.rip.lfreq)
        subplot(3,1,3);
        circ_plot(phases,'hist',[],20,true,true,'linewidth',2,'color','r');
        hold on;
        polar(0, max(N),'-k');
        hold off;
        
        set(gca, ap.pl.textprop, ap.pl.textpropval);
        hold on;
        line(mean_angle, 60);
        hold off;
        [ph_p, ~] = circ_rtest(phases);
        title(sprintf('Phase distribution of max on %s: mphase = %3.0f, p = %4.1f', ap.rip.lfreq, mean_angle, ph_p));
    end

    if dosave
        save_figure(h,export_dir_get(data_ap), fname);
    end
end

function [Xfilt, nbands] = filter_conds(X, ap)

ncond = numel(X);
[~,nbands] = size(ap.fb.ranges);

for i=1:nbands
    fbanks(i) = window_FIR(ap.fb.ranges(1,i), ap.fb.ranges(2,i), ap.srate);
end

for i=1:ncond
    Xfilt{i} = do_filt(fbanks, X{i});
end

function [Xfilt] = do_filt(fbanks, X)

parfor j=1:numel(fbanks)
    Xfilt(:,j) = filtfilt(fbanks(j).Numerator, 1, X);
end

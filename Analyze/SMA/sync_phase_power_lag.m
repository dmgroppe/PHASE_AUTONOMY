function [pcorr_lag, lag_max] = sync_phase_power_lag(EEG, ch, cond, ptname, dosave)

if nargin < 5; dosave = 0; end;

% Save the analysis info in AP
ap = sync_params();
ap.condlist{1} = cond;
ap.ptname = ptname;
ap.chlist = ch;

% Get the data
[tstart tend] = get_trange(cond, ap.length, ptname);
subr = get_subregion(EEG, tstart, tend);
subr = subr(ch,:);

if ap.surr
    subr(1,:) = subr(1,end:-1:1);
end

% Wavelet transforms

if length(ap.freqs)== 2
    d = window_FIR(ap.freqs(1), ap.freqs(2), EEG.srate);
    wt1 = filtfilt(d.Numerator, 1,subr(1,:));
    wt2 = filtfilt(d.Numerator, 1,subr(2,:));
    nfreqs = 1;
else
    wt1 = twt(subr(1,:), EEG.srate, linear_scale(ap.freqs, EEG.srate), ap.wnumber);
    wt2 = twt(subr(2,:), EEG.srate, linear_scale(ap.freqs, EEG.srate), ap.wnumber);
    nfreqs = length(ap.freqs);
end

% The Sync-Power Corr for all the frequencies
wind_length = fix(ap.wind_length/EEG.srate*1000);
plags = fix(ap.plags/EEG.srate*1000);
parfor i=1:nfreqs
    [pcorr_lag(:,i)] = sync_ppc_lag(wt1(i,:), wt2(i,:), wind_length, plags);
end

h = figure(1);
zrange = [min(min(pcorr_lag)) max(max(pcorr_lag))];
xrange = [plags(1) plags(end)];


if nfreqs == 1
    plot(plags, pcorr_lag);
    xlabel('Lag (ms)');
    ylabel('Correlation');
    
    if ~isempty(ap.yaxis)
        yaxis = ap.yaxis;
    else
        yaxis = zrange;
    end
    axis([xrange yaxis]);
    
    fprintf('\nPairs: %d & %d', ch(1), ch(2));
    fprintf('\nFor frequency of %d\n', ap.freqs);
    pc_max = max(pcorr_lag);
    lag_max = plags(find(pcorr_lag == pc_max));
    fprintf('\nPeak of s%6.2f occurs at lag = %6.1f ms\n', pc_max, lag_max);
    
else
    frange = [ap.freqs(1) ap.freqs(2)];
    surf(plags, frange, pcorr_lag');
    
    if ~isempty(ap.yaxis)
        zaxis = [ap.yaxis];
    else
        zaxis = zrange;
    end
    axis([xrange, yrange, zaxis])
    shading interp;
    view(0,90);
end
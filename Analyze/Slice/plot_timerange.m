function [] = plot_timerange(S, trange, yrange, dec, pap)

[nchan, npoints] = size(S.data);

if nargin < 5
    trunc = 0;
else
    trunc = 3*fix(1/min(pap.wt.freqs))*pap.srate;
end

if (2*trunc >= npoints)
    error('Data segment too short for desired frequencies');
end

T = (0:npoints-1)/S.srate;
t = T((trunc+1):end-trunc);
x = S.data(:, (trunc+1):end-trunc);

if isempty(trange)
    tstart = t(1);
    tend = t(end);
else
    tstart = trange(1);
    tend = trange(2);
end

tplot = find(t>= tstart & t<=tend);
if isempty(tplot)
    error('Time ranges out of bounds');
end

di = tplot(1):dec:tplot(end);

for i=1:nchan
    ax(i) = subplot(nchan,1,i);
    
    if i == 2
        hpfilt = window_highpass(10,S.srate,2000);
        y = x(i, di);
        y = filtfilt(hpfilt.Numerator,1, y);
        y = detrend(smooth(y,200));
    else
        y = x(i, di);
    end
    
    plot(t(di), y );
    if ~isempty(yrange)
        axis([tstart tend yrange(i,:)]);
    else
        axis([tstart tend min(y) max(y)]);
    end

end
linkaxes(ax, 'x');



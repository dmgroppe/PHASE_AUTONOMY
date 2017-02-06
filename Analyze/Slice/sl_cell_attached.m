function [] = sl_cell_attached(S, trange, chan)

minpeakdist = 1;
mult = 20;
pre_w = 20;
post_w = 50;
interp_fac = 10;
y_lim = [-200 250];
thresh = 40;

[nchan npoints] = size(S.data);
% The time range of analysis
T = (0:(npoints-1))/S.srate;
t = find(T>= trange(1) & T<=trange(2)); % subregion time range
ts = -S.data(chan, t);

figure(1);clf;
plot(T(t),ts);
%thresh = mult*median(abs(ts))/0.6745;

[~,loc] = findpeaks(ts, 'MINPEAKDISTANCE', minpeakdist);
pind = find(ts(loc) > thresh);
pind = loc(pind);

hold on;
plot(T(t(pind)), ts(pind), '.r', 'LineStyle', 'none', 'MarkerSize', 5);
hold off;

ts_length = length(ts);
count = 0;
t_spike = (0:(post_w+pre_w-1))/S.srate*1000;
t_spike_interp = t_spike(1):t_spike(2)/interp_fac:t_spike(end);

for i=1:length(pind)
    tstart = pind(i) - pre_w;
    tend = pind(i) + post_w-1;
    if ~(tstart <= 0 || tend >= ts_length)
        count = count + 1;
        spikes(:,count) = ts(tstart:tend);
        spikes_interp(:,count) = spline(t_spike, spikes(:,count), t_spike_interp);
    end
end

% figure(2);clf;
% subplot(2,1,1);
% 
% plot(repmat(t_spike, count,1)', spikes);
% axis([t_spike(1) t_spike(end) ylim]);
% 
% subplot(2,1,2);
% plot(t_spike, mean(spikes,2));
% axis([t_spike(1) t_spike(end) ylim]);

% Plot the interpolated spikes
figure(2);clf;
subplot(2,1,1);

plot(repmat(t_spike_interp, count,1)', spikes_interp);
axis([t_spike(1) t_spike_interp(end) y_lim]);

subplot(2,1,2);
plot(t_spike_interp, mean(spikes_interp,2));
axis([t_spike_interp(1) t_spike_interp(end) y_lim]);
title(sprintf('# spikes = %d', count));



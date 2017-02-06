function [] = sync_2freqp_evolution(EEG, ch, franges, ptname, dosave)

if nargin < 5; dosave = 0; end;

sspan = 1000;
sm_method = 'moving';
pcorr_window = 250;
yaxis_range = [0 2];

ap = sync_params();

condlist = {'aloud', 'quiet', 'rest_eo', 'rest_ec'};

if min(size(franges)) < 2
    display('Need at least two frequency ranges');
    return;
end

d = window_FIR(franges(1,1), franges(2,1), EEG.srate);
x1 = filtfilt(d.Numerator, 1, EEG.data(ch,:));

d = window_FIR(franges(1,2), franges(2,2), EEG.srate);
x2 = filtfilt(d.Numerator, 1, EEG.data(ch,:));

T = (1:length(x1))/EEG.srate;  % Time in seconds

p1 = abs(hilbert(x1));
p2 = abs(hilbert(x2));

ymax = max([max(p1) max(p2)]);
ymin = min([min(p1) min(p2)]);

if isempty(yaxis_range)
    yaxis_range = [0 ymax];
end

h = figure(1);
set(h, 'Name', 'Power');
subplot(2,1,1);

if sspan > 0
    plot(T, smooth(p1, sspan, sm_method));
else
    plot(T, p1);
end

axis([T(1) T(end) yaxis_range]);
legend(sprintf('%d-%d', franges(1,1), franges(2,1)));
xlabel('Time(s)');
ylabel('Power uv^2');

subplot(2,1,2);

if sspan > 0
    plot(T, smooth(p2, sspan, sm_method));
else
    plot(T, p2);
end

xlabel('Time(s)');
ylabel('Power uv^2');
axis([T(1) T(end) yaxis_range]);
legend(sprintf('%d-%d', franges(1,2), franges(2,2)));
fname = sprintf('Power full data %s CH%d %d-%d %d-%d', ptname, ch,...
    franges(1,1), franges(2,1), franges(1,2), franges(2,2));

if dosave
    save_figure(h, get_export_path_SMA(), fname);
end

h = figure(2);
set(h, 'Name', 'R2');
[rho, ~, means] = pcorr(x1, x2, pcorr_window);
Tcorr = (1:length(rho))*pcorr_window/EEG.srate;
%sm_rho = smooth(rho,pcorr_window/10);
sm_rho = rho;
plot(Tcorr, sm_rho);
axis([Tcorr(1) Tcorr(end) min(sm_rho) max(sm_rho)])
fname = sprintf('R2 TS data %s CH%d %d-%d %d-%d', ptname, ch,...
    franges(1,1), franges(2,1), franges(1,2), franges(2,2));

if dosave
    save_figure(h, get_export_path_SMA(), fname);
end

% Do regression on mean power over pcorr_window length intervals

h = figure(3);
set (h, 'Name', 'R2 conditions');

for i=1:numel(condlist)
    [tstart tend] = get_trange(condlist{i}, ap.length, ptname);
    sstart = tstart/1000*EEG.srate;
    send = tend/1000*EEG.srate;
    
    bstart = fix(sstart/pcorr_window);
    bend = fix(send/pcorr_window);
    x1= means(1,bstart:bend);
    x2= means(2,bstart:bend);
    ymax = max(max(means(:,bstart:bend)));
    
    
    [rho, pval] = corr(x1',x2','type','Spearman');
    subplot(2,2,i);
    plot(x1, x2, 'LineStyle', 'none', 'Marker', '.', 'MarkerSize', 10);
    hold on;
    [yfit, ~] = linear_fit(x1, x2);
    plot(x1, yfit, 'g');
    hold off
    axis([0 ymax 0 ymax]);
    axis square;
    title(upper(condlist{i}));
    xlabel('M1');
    ylabel('M2');
    legend(sprintf('R = %4.2f, p = %e', rho, pval));
    
    avgp1 = mean(p1(sstart:send));
    avgp2 = mean(p2(sstart:send));
    
    fprintf('\nAvg power during %s at %d-%d = %6.4f uV\n', upper(condlist{i}),...
        franges(1,1), franges(2,1), avgp1);
    
      fprintf('Avg power during %s at %d-%d = %6.4f uV\n', upper(condlist{i}),...
        franges(1,2), franges(2,2), avgp2);
    
   p = ranksum(p1(sstart:send), p2(sstart:send));
   fprintf('p = %e\n', p);
    
end

fname = sprintf('R2 Conditions data %s CH%d %d-%d %d-%d', ptname, ch,...
    franges(1,1), franges(2,1), franges(1,2), franges(2,2));

if dosave
    save_figure(h, get_export_path_SMA(), fname);
end


function [rho, pval, means] = pcorr(x1, x2, window)

set(0,'RecursionLimit',window*2);

index = 1:window:length(x1);
ranges = [index(1:end-1)',index(2:end)'-1];

rho = zeros(1,length(ranges));
pval = rho;


for i=1:length(ranges)
    sstart = ranges(i,1);
    send = ranges(i,2);
    %send = sstart + wlength - 1;
    a1 = abs(x1(sstart:send));
    a2 = abs(x2(sstart:send));
    [rho(i), pval(i)] = corr(a1',a2','type','Spearman');
    means(:,i) = [mean(a1), mean(a2)];
end



function [yfit, stats] = linear_fit(x1, x2)
X = [ones(size(x1))', x1'];
[b,~,~,~,stats] = regress(x2',X);
yfit = b(1) + b(2)*x1;


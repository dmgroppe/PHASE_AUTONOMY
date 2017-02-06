function [] = sync_2fppc(EEG, channels, f1, f2, cond, ptname, dosave)

% Computes the correlation of the phase-dependant power correlations of two
% frequencies

if nargin < 7; dosave = 0; end;

ap = sync_params();

[tstart tend] = get_trange(cond, ap.length, ptname);
subr = get_subregion(EEG, tstart, tend);
subr = subr(channels,:);

% Generate the time series
[x1f1, hx1f1] = hfilt(subr(1,:),f1, EEG.srate);
[x1f2, hx1f2] = hfilt(subr(1,:),f2, EEG.srate);


[x2f1, hx2f1] = hfilt(subr(2,:),f1, EEG.srate);
[x2f2, hx2f2] = hfilt(subr(2,:),f2, EEG.srate);

% Create the segments
segi = 1:ap.tfppc.window:length(x1f1);
segs = [segi(1:end-1)' segi(2:end)'-1];

% Plot simple power correlation of the two frequencies
[~, centers] = make_phase_bins(ap.ppc.nbins);

for i=1:length(segs)
    [~, ~, rho, ~, bins, ~] = sync_ppc(hx1f1(segs(i,1):segs(i,2)), hx2f1(segs(i,1):segs(i,2)), ap.ppc.nbins);
    amp1(i) = sync_ppc_amps(centers, rho);
    
    [~, ~, rho, ~, bins, ~] = sync_ppc(hx1f2(segs(i,1):segs(i,2)), hx2f2(segs(i,1):segs(i,2)), ap.ppc.nbins);
    amp2(i) = sync_ppc_amps(centers, rho);
end

h = figure(1);
fname = sprintf('TFPPC %s %s %d&%d, %d-%d %d-%d', upper(ptname), upper(cond),...
    channels(1), channels(2), f1(1), f1(2), f2(1), f2(2));
set(h, 'Name', fname);

plot(amp1,amp2, '.', 'LineStyle', 'none', 'MarkerSize', 15);
[rho, p] = corr(amp1',amp2','type','Spearman');
xlabel(sprintf('Amp %d-%d', f1(1), f1(2)));
ylabel(sprintf('Amp %d-%d', f2(1), f2(2)));
legend(sprintf('r = %6.2f, p = %6.2f',rho,p));
axis square;
axis([0 1 0 1]);
set(gca, 'TickDir', 'out');

hold on;
X = [ones(size(amp1))', amp1'];
[b,~,~,~,~] = regress(amp2',X);
yfit = b(1) + b(2)*amp1;
plot(amp1,yfit, 'g');
hold off;


if dosave
    save_figure(h, get_export_path_SMA(), fname);
end




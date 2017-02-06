function [] = sync_ppc_fit(EEG, frange, channels, cond, ptname, dosave)

if nargin < 6; dosave = 0; end;

ap = sync_params();
[~,x] = make_phase_bins(ap.ppc.nbins);

if isempty(ap.yaxis)
    yaxis = [-0.2 1];
else
    yaxis = ap.yaxis;
end

ts = data_retrieve(EEG, cond, ap.length, ptname);
ts = ts(channels,:);

ts_filt = filter_t(ts, frange,EEG.srate);

parfor i=1:size(ts_filt,1)
    ts_hilbert(i,:) = hilbert(ts_filt(i,:));
end

[~, ~, rho, ~, ~, mean_phase] = sync_ppc(ts_hilbert(1,:), ts_hilbert(2,:), ap.ppc.nbins, ap.ppc.ctype);

%mean_phase = -mean_phase;

h = figure(1);
clf('reset');
fname = sprintf('PPC FIT %s %s %d-%d %d-%d', upper(ptname), upper(cond), channels(1), channels(2),...
    frange(1), frange(2));
set(h, 'Name', fname);
subplot(2,2,1);
plot(x,rho, '.', 'LineStyle', 'None', 'MarkerSize', 15);
[beta,resid,J,COVB,mse] = nlinfit(x,rho,@ff_bidir, [0.5, 0.5, mean_phase, mean(frange)]);
hold on;
fitx = -pi:0.1:pi;
plot(fitx,ff_bidir(beta,fitx), 'g');
hold off;

axis([-pi pi yaxis]);
set(gca, 'TickDir', 'out');
axis square;
title('Bidirectional coupling');
xlabel('Radians');
ylabel('PDPC');

ci = nlparci(beta,resid,'jacobian',J);
l1 = sprintf('w1 = %4.2f, w2 = %4.2f', beta(1), beta(2));
l2 = sprintf('w1 = %4.2f-%4.2f; w2 = %4.2f-%4.2f', ci(1,1), ci(1,2), ci(2,1), ci(2,2));

legend({l1,l2});

% As discussed in the paper the PC can used to estimate the weighting in
% unidirectional case

PC = phase_coherence(ts_hilbert(1,:), ts_hilbert(2,:));

% compute the unidrection phase-dependant power correlations
[pdpc_unidir] = pdpc(PC,fitx);

subplot(2,2,2);
plot(x,rho, '.', 'LineStyle', 'None', 'MarkerSize', 15);
hold on;
plot(fitx, pdpc_unidir, 'g');
hold off;
axis([-pi pi yaxis]);
set(gca, 'TickDir', 'out');
axis square;
title('Unidirectional');
xlabel('Radians');
ylabel('PDPC');

[beta,resid,J,COVB,mse] = nlinfit(x,rho,@pdpc, 0.5);
hold on;
plot(fitx, pdpc(beta,fitx), 'm');
l2 = sprintf('PC = %4.2f', PC);
l3 = sprintf('Fitted w = %4.2f', beta);
legend({'PDPC', l2, l3});

% Fit to a cosine function

subplot(2,2,4);
plot(x,rho, '.', 'LineStyle', 'None', 'MarkerSize', 15);
axis([-pi pi yaxis]);
set(gca, 'TickDir', 'out');
axis square;
title('Cosine fit');
xlabel('Radians');
ylabel('PDPC');

[beta,resid,J,COVB,mse] = nlinfit(x,rho,@cos_fit, [0.5 0]);
hold on;
plot(fitx, cos_fit(beta,fitx), 'g');
legend({'PDPC', 'Fit'});

if dosave
    save_figure(h, get_export_path_SMA(), fname);
end

%Fit to common drive model

subplot(2,2,3);
plot(x,rho, '.', 'LineStyle', 'None', 'MarkerSize', 15);
[beta,resid,J,COVB,mse] = nlinfit(x,rho,@pdpc_cmndrive, [0.6, 0]);
hold on;
fitx = -pi:0.1:pi;
plot(fitx,pdpc_cmndrive(beta,fitx), 'g');
hold off;
axis([-pi pi yaxis]);
set(gca, 'TickDir', 'out');
axis square;
title('Common Drive');
xlabel('Radians');
ylabel('PDPC');

ci = nlparci(beta,resid,'jacobian',J);
l1 = sprintf('w = %4.2f, P = %4.2f rad', beta(1), beta(2));
l2 = sprintf('w = %4.2f-%4.2f; P = %4.2f-%4.2f rad', ci(1,1), ci(1,2), ci(2,1), ci(2,2));
legend({l1,l2});

return;

%% Perform same calculations over wavelet transformed data

display('Performing wavelet transforms...');
wt1 = twt(ts(1,:), EEG.srate, linear_scale(ap.freqs, EEG.srate), ap.wnumber);
wt2 = twt(ts(2,:), EEG.srate, linear_scale(ap.freqs, EEG.srate), ap.wnumber);

[Rbd, Rud, R, xfit] = sync_ppc_afit(wt1, wt2, ap);

for i=1:length(ap.freqs)
    rbd(i,:) = Rbd(i).fit;
    wratio(i) = Rbd(i).beta(1)/Rbd(i).beta(2);
    depth(i) = max(Rbd(i).fit) - min(Rbd(i).fit);
end

h = figure(2);
subplot(3,1,1);
surf(xfit,ap.freqs,rbd);
axis([-pi pi ap.freqs(1) ap.freqs(end) yaxis]);
view(0,90);
shading interp;
title('PDPC - bidirectional');
xlabel('Frequency (Hz)');
ylabel('PDPC');
%axis square;

subplot(3,1,2);
zindex = fix((length(xfit)-1)/2);
ppc0 = rbd(:,zindex);
plot(ap.freqs,ppc0, ap.freqs, depth);
axis([ap.freqs(1) ap.freqs(end) yaxis]);
title('Good phase');
xlabel('Frequency (Hz)');
ylabel('PDPC');

subplot(3,1,3);
plot(ap.freqs,wratio);
axis([ap.freqs(1) ap.freqs(end) min(wratio) max(wratio)]);
title('Coupling ratio');
xlabel('Frequency (Hz)');
ylabel('w1/w2');

h = figure(3);
set(h, 'Name', 'Rho');
plot_ppc(x, R.rho, ap);
title('Rho - unadulterated');


h = figure(5);
set(h, 'Name', 'Rho at 127.5Hz');
findex = find(ap.freqs == 127.5);
if ~isempty(findex)
    plot(x, R.rho(findex,:), '.', 'LineStyle', 'None', 'MarkerSize', 15);
    hold on;
    plot(xfit, Rbd(findex).fit, 'g');
    display(sprintf('w1 = %4.2f, w2 = %4.2f mp = %4.2f',Rbd(findex).beta(1), Rbd(findex).beta(2), R.mean_phase(findex)));
end
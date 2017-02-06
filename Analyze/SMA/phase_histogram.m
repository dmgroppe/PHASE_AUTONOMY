% USAGE: [phist] = phase_histogram(EEG, ch, frange, cond, length, npeaks)


function [phist] = phase_histogram(EEG, ch, frange, cond, slength, ptname, npeaks, dosave)

if nargin < 8; dosave = 1; end;
if nargin < 7; npeaks = 1; end;
if nargin < 6; ptname = 'vant'; end;

ap = sync_params();


eDir = 'D:\Projects\Data\Vant\Figures\Phase Histograms\';
nbins = 100;

[tstart tend] = get_trange(cond, slength, ptname);
subr = get_subregion(EEG, tstart, tend);

d = window_FIR(frange(1), frange(2), EEG.srate);
h1 = hilbert(filtfilt(d.Numerator,1,subr(ch(1),:)));
h2 = hilbert(filtfilt(d.Numerator,1,subr(ch(2),:)));

%h1 = twt(subr(1,:), EEG.srate, linear_scale(frange(1), EEG.srate), ap.wnumber);
%h2 = twt(subr(2,:), EEG.srate, linear_scale(frange(1), EEG.srate), ap.wnumber);



%h1 = hilbert(eegfilt(double(subr(ch(1),:)), EEG.srate, frange(1), frange(2)));
%h2 = hilbert(eegfilt(double(subr(ch(2),:)), EEG.srate, frange(1), frange(2)));

a1 = abs(h1);
a2 = abs(h2);

dphi = phase_diff(angle(h1) - angle(h2));

[pval z] = circ_rtest(dphi);
mphase = circ_mean(dphi);
fprintf('\nRayleigh test: p = %7.5f, mean angle = %6.4f radians\n', pval, mphase);
fprintf('\n Time delay at this frequency = %6.2f\n', mphase/(2*pi)/mean(frange)*1000);
%[h mu ul ll] = circ_mtest(dphi, 0, .05)

text = sprintf('P-hist %s %d-%d,%4.0f-%4.0fHz', upper(cond), ch(1), ch(2),...
    frange(1), frange(2));

phist = hist(dphi, nbins);

if nargin == 1
    return
end

h = figure(10);
%rose(dphi);
%hold on;
rose(mphase*ones(1,length(dphi)));
%hold off;

if (dosave)
    save_figure(h,eDir, [text ' ROSE']);
end

x = -pi:2*pi/99:pi;
text = sprintf('P-hist %s %d-%d,%4.0f-%4.0fHz', upper(cond), ch(1), ch(2),...
    frange(1), frange(2));

h = figure(1);
figtext = [text ' Peak fit'];
set(h, 'Name', text);
%peakfit(dphi,center,window,NumPeaks,peakshape,extra,NumTrials,start)
[FitResults,LowestError,BestStart,xi,yi] = peakfit([x' phist'],0,2*pi,npeaks,1,1,20);

if (dosave)
    save_figure(h,eDir, figtext);
end

% Plot cumulative PDFs

h = figure(2);
figtext = [text ' Cumulative PDF'];
set(h, 'Name', figtext);
npoints = max(size(xi));
a = zeros(1,npoints);

for i=1:npeaks
    for j=1:npoints
        a(j) = sum(yi(i,1:j));
    end
    a = a/max(a);
    subplot(npeaks,1,i);
    plot(xi,a);
end
title(figtext);

if(dosave)
    save_figure(h,eDir, figtext);
end

% Plot the fits on the histograms

h = figure(3);
figtext = [text ' Histograms'];
set(h, 'Name', figtext);
hist(dphi, 100);
hold on

if (npeaks > 1)
    yi(npeaks+1,:) = sum(yi);
else
    yi(npeaks+1,:) = yi;
end

for i=1:npeaks
    plot(xi,yi(i,:), '-w');
end
plot(xi,yi(npeaks+1,:), '-g');
title(figtext);
xlabel('Phase Difference (radians)');
ylabel('Count')
hold off

if (dosave)
    save_figure(h,eDir, figtext);
end

%  Look at non zero peaks and determine the amplitudes at the different
%  peaks

N = max(size(a1));

counts = 0;
for j=1:N
    if (dphi(j)< 0)
        counts = counts +1;
        amps(counts) = a1(j)*a2(j);
    end
end
amean(1) = mean(amps);

counts = 0;
amps = [];
for j=1:N
    if (dphi(j)> 0)
        counts = counts +1;
        amps(counts) = a1(j)*a2(j);
    end
end

amean(2) = mean(amps);

% Fit the data to Von Mises distribution

% reorder the estimates as beta0 for the fit
beta0 = [];
x = -pi:(2*pi/(nbins-1)):pi;
for i=1:npeaks
    beta0 = [beta0 FitResults(i,3) FitResults(i,2) 1];
end
[beta, pfit, ps, error] = vm_fit(x,phist,npeaks,beta0);

figure(4);
plot(x,phist,'.','MarkerSize',5);
hold on;
plot(x,pfit,'g');

for i=1:npeaks
    plot(x, ps(:,i), 'r');
end

hold off;

for i=1:npeaks
    index = (i-1)*3 + 1;
    fprintf('Peak %d: height %4.2f, mu %4.2f, k %4.2f\n',i,  beta(index), beta(index+1), beta(index+2));
end
fprintf('RMS error = %4.2f\n', error);

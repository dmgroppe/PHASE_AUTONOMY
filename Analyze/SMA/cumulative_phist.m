function [] = cumulative_phist(EEG, ch_pairs, frange, cond, length, ptname, npeaks, dosave)

if min(ch_pairs) < 2
    display('Requires pairs, not a channel list.')
    return;
end

nbins = 200;

% Get the appropriate subregion
[tstart tend] = get_trange(cond, length, ptname);
subr = get_subregion(EEG, tstart, tend);

% Make the filter
d = window_FIR(frange(1), frange(2), EEG.srate);

npairs = size(ch_pairs,2);

for i=1:npairs

    h1 = hilbert(filtfilt(d.Numerator,1,subr(ch_pairs(1,i),:)));
    h2 = hilbert(filtfilt(d.Numerator,1,subr(ch_pairs(2,i),:)));

    dphi = (angle(h1) - angle(h2))/2;
    dphi = phase_diff(dphi).*sign(dphi);
    
    phist(:,i) = hist(dphi, nbins);
end

cum_hist = squeeze(sum(phist,2));

x = -pi:2*pi/(nbins-1):pi;

h = figure(1);
text = sprintf('Cumulative Histogram %s %4.0f-%4.0fHz', upper(cond), frange(1), frange(2));
figtext = [text ' Peak fit'];
set(h, 'Name', text);
[FitResults,LowestError,BestStart,xi,yi] = peakfit([x' cum_hist],0,2*pi,npeaks,1,1,20);

if (dosave)
    save_figure(h,get_export_path_SMA(), figtext);
end


% Fit the data to Von Mises distribution

% reorder the estimates as beta0 for the fit
beta0 = [];
x = -pi:(2*pi/(nbins-1)):pi;
for i=1:npeaks
    beta0 = [beta0 FitResults(i,3) FitResults(i,2) 1];
end
[beta, pfit, ps, error] = vm_fit(x,cum_hist',npeaks,beta0);

h = figure(2);
figtext = [figtext ' Von Mises fit'];
set(h, 'Name', figtext);

plot(x,cum_hist,'.','MarkerSize',15);
hold on;
plot(x,pfit,'g');

for i=1:npeaks
    plot(x, ps(:,i), 'r');
end
hold off;
axis([-pi pi 0, max(cum_hist)]);

if (dosave)
    save_figure(h,get_export_path_SMA(), figtext);
end

for i=1:npeaks
    index = (i-1)*3 + 1;
    fprintf('Peak %d: height %4.2f, mu %4.2f, k %4.2f\n',i,  beta(index), beta(index+1), beta(index+2));
end
fprintf('RMS error = %4.2f\n', error);


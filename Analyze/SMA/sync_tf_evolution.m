function [] = sync_tf_evolution(EEG, ch_pair, frange, atype, window)

ap = sync_params();
ap.yaxis = [0 1.0];
condlist = {'aloud', 'quiet', 'rest_eo'};

x = EEG.data(ch_pair, :);
d = window_FIR(frange(1), frange(2), EEG.srate);
xfilt = filtfilt(d.Numerator, 1, x')';
T = (1:length(x))/EEG.srate;

% [tstart,tend] = get_trange(condlist{1}, ap.length, ap.ptname);
% voice_from_ts(xfilt(2,tstart:tend),EEG.srate);

% Display the wavelet spectrum
wt1 = twt(x(1,:), EEG.srate, linear_scale(ap.freqs, EEG.srate), ap.wnumber);
wt2 = twt(x(2,:), EEG.srate, linear_scale(ap.freqs, EEG.srate), ap.wnumber);


figure(2);

subplot(2,1,1);
surf(T,ap.freqs,abs(wt1));
shading interp;
view(0,90);

subplot(2,1,2);
surf(T,ap.freqs,abs(wt2));
shading interp;
view(0,90);

return;

% Do the sync calculation

hx = hilbert(xfilt')';

fh = sync_fh(atype);

tic
parfor i=1:length(x)-window
    sync(i) = compute_sync(hx, i, window, fh);
end
toc

if strcmp(atype, 'ic')
    sync = abs(sync);
end

if ap.sm_span > 0
    sm_sync = smooth(sync, ap.sm_span, ap.sm_method);
else
    sm_sync = sync;
end
    

h = figure(1);
fname = sprintf('Two chan sync %d-%d %d-%dHz', ch_pair(1), ch_pair(2), frange(1), frange(2));
set(h, 'Name', fname);
plot(T,sm_sync);
xlabel('Time (s)');
ylabel(upper(atype));

if ~isempty(ap.yaxis)
    axis([T(1) T(end) ap.yaxis]);
end

save_figure(h, get_export_path_SMA(), fname);

% Compare the variances during the different states
%  Only works if EEG and ap.ptname are consistent
display('Ensure EEG corresponds to ap.ptname for propoer variance calculations');

for i=1:length(condlist)
    [tstart,tend] = get_trange(condlist{i}, ap.length, ap.ptname);
    times(:,i) = [tstart tend]/1000*EEG.srate;
end

ialoud =1;
iquiet = 2;
irest =  3;

[~,p] = ansaribradley(sync(times(1,ialoud):times(2,ialoud)), ...
    sync(times(1,irest): times(2,irest)));
fprintf('\n Aloud vs Rest EO, p = %e', p);

[~,p] = ansaribradley(sync(times(1,iquiet):times(2,iquiet)), ...
    sync(times(1,irest): times(2,irest)));
fprintf('\n Quiet vs Rest EO, p = %e', p);

[~,p] = ansaribradley(sync(times(1,ialoud):times(2,ialoud)), ...
    sync(times(1,iquiet): times(2,iquiet)));
fprintf('\n Aloud vs Quiet, p = %e', p);

% Display the wavelet spectrum
wt1 = twt(x(1,:), EEG.srate, linear_scale(ap.freqs, EEG.srate), ap.wnumber);
wt2 = twt(x(2,:), EEG.srate, linear_scale(ap.freqs, EEG.srate), ap.wnumber);


figure(2);

subplot(2,1,1);
surf(T,ap.freqs,wt1);
shading interp;
view(0,90);

subplot(2,1,2);
surf(T,ap.freqs,wt2);
shading interp;
view(0,90);







function [sync] = compute_sync(hx, i, window, fh)
sync = fh(hx(1,i:i+window-1), hx(2,i:i+window-1));








function [EEGCGT R] = sync_autocoh(EEG, ch, cond, ptname, freqs, doplot)

% Computes the autocoherence of a signal

if nargin < 6; doplot = 1; end;

% Save the analysis info in AP
ap = sync_params();

% Get the atuo_params from a separate file.  These parameters are specific
% to each channel for the simulation portion of the analysis.
ap = autocoh_params(ap,ptname,ch);

ap.condlist{1} = cond;
ap.ptname = ptname;
ap.chlist = ch;

% Get time ranges for the condition of interest
[tstart tend] = get_trange(cond, ap.length, ptname);
sstart = floor(tstart*EEG.srate/1000);
send =  floor(tend*EEG.srate/1000)-1;

% Check to see what kind of data was passed
if isfield(EEG, 'cgt')
    fullgt = EEG.cgt;
    freqs = EEG.freqs;
    EEGCGT = [];
else
    display('Computing Gabor transform...');
    fullgt = cgt(EEG.data(ch,:), ap.autocoh.dt, freqs, EEG.srate);
    % Save the cgt into an eeg structure
    EEGCGT.data = EEG.data(ch,:);
    EEGCGT.cgt = fullgt;
    EEGCGT.freqs = freqs;
    EEGCGT.srate = EEG.srate;
    EEGCGT.cond = cond;
    EEGCGT.ptname = ptname;
    EEGCGT.ch = ch;
end

npoints = length(fullgt);

% Compute the mean and std of the Gabor Transform over the entire time
% series
m = mean(abs(fullgt), 2);
s = std(abs(fullgt),1,2);
Zfull = (abs(fullgt)-repmat(m,1,npoints))./repmat(s,1,npoints);
Z = Zfull(:,sstart:send);


% Analysis section
phi = angle(fullgt(:,sstart:send));
[R] = autocoh_run_analysis(Z, phi, freqs,ap, EEG.srate);

% Plotting section
if doplot
    h=figure(1);
    ftext = sprintf('Autocoherence analysis %s CH%d: Burst features', upper(ptname), ch);
    set(h,'Name', ftext);
    plot_autocoh(ap, R, EEG.srate, freqs);
end
function [R_surr R_bursts] = sync_autocoh_surr(EEG, R, surr_type, doplot, ap)


% Computes the autocoherence of a signal
if nargin < 4; doplot = true; end;

if nargin < 5
    ap = sync_params();
    
    % Get the autocoh_params from a separate file.  These parameters are specific
    % to each channel for the simulation portion of the analysis.
    ap = autocoh_params(ap,EEG.ptname,EEG.ch);
end

% Get time ranges for the condition of interest
[tstart tend] = get_trange(EEG.cond, ap.length, EEG.ptname);
sstart = floor(tstart*EEG.srate/1000);
send =  floor(tend*EEG.srate/1000)-1;

fullgt = EEG.cgt;
freqs = EEG.freqs;
ts = EEG.data(sstart:send);

% Compute the mean and std of the Gabor Transform over the entire time
% series
m = mean(abs(fullgt), 2);
s = std(abs(fullgt),1,2);

% Do some simulation stuff here
%surr = ts';

R_bursts = {};
R_surr = {};
display('Generating surrogates...');
if strcmpi(surr_type,'noise')
    tic;
    parfor i=1:ap.autocoh.nsurr
        [surr(:,i),~]=IAAFT(ts,1);
    end
    toc;
else
    parfor i=1:ap.autocoh.nsurr
        [surr(:,i), bursts(:,i) R_bursts{i}] = sim_burst2(R, EEG, ap, freqs);
    end
end

if doplot
    figure(10);
    clf;
    subplot(3,1,1);
    T = (0:(length(ts)-1))/EEG.srate;
    plot(T, ts, T, surr(:,1));
    subplot(3,1,2);
    if ~strcmpi(surr_type,'noise')
        plot(T,bursts(:,1));
    end
    subplot(3,1,3)
    plot_spectra(ts, surr(:,1)', EEG.srate, {'TS','SURR'});

    % Plot the rest power spectrum
    [sstart send] = get_samples(EEG,'rest_eo',ap,EEG.ptname);
    if isfield(EEG, 'cgt')
        rest = EEG.data(sstart:send);
    else
        rest = EEG.data(ch, sstart:send);
    end
    [ps_rest,w,~] = powerspec(rest, EEG.srate, EEG.srate);
    hold on;
    plot(w, ps_rest, 'r');
    hold off;
end


% Exit if just checking the fit of the PS
if ap.autocoh.check_fit
    return;
end

if ~ap.autocoh.use_periodic
    % Run the surrogates (or not)
    display('Running burst analysis...');
    if ap.autocoh.nsurr == 1
        R_surr{1} = run_single_surr(surr(:,1), m, s, ap, freqs, EEG.srate);
    else
        srate = EEG.srate;
        parfor k=1:ap.autocoh.nsurr
            R_surr{k} = run_single_surr(surr(:,k), m, s, ap, freqs, srate);
            % Too much data, that is not required, otherwise fills up the
            % entire memory
            R_surr{k}.lengths = [];
            R_surr{k}.ranges = [];
            R_surr{k}.all_ranges = [];
            R_surr{k}.bursts = [];
        end
    end

    if doplot && ap.autocoh.nsurr == 1
        h=figure(2);
        fname = sprintf('Autocoherence for %s type surrogate: %s CH%d',...
            upper(surr_type), EEG.ptname, EEG.ch);
        set(h,'Name', fname);
        plot_autocoh(ap, R_surr{1}, EEG.srate, freqs);
    end
else
    if ap.autocoh.nsurr == 1
        [R_surr ~] = autocoh_periodic(surr(:,1)', EEG.srate, ap.autocoh.periodic.frange,...
        ap.autocoh.periodic.fwindow, ap.autocoh.periodic.nperm, ap.autocoh.bsize, ap.autocoh.useall);
    end
end


function [R_surr] = run_single_surr(surr, m, s, ap, freqs, srate)
gt = cgt(surr, ap.autocoh.dt, freqs, srate);
Z = (abs(gt)-repmat(m,1,length(gt)))./repmat(s,1,length(gt)); 
R_surr = autocoh_run_analysis(Z, angle(gt), freqs,ap, srate);





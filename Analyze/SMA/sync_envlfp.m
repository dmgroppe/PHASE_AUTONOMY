function [sync, env_wt, lfp_wt] = sync_envlfp(EEG, ch, ptname, cond, envfrange, surr, doplot)

if nargin < 7; doplot = 0; end;
if nargin < 6; surr = 0; end;

% Computes the specified synch between two EEG taking the envelope of one
% in a specified frequnecy range, and the LFP of the other.

ap = sync_params();

% Get the data
ts = data_retrieve(EEG, cond, ap.length, ptname);
ts = ts(ch,:);


% Filter in the envelope range, then get the envelope of the signal
d = window_FIR(envfrange(1), envfrange(2), EEG.srate);
env = abs(hilbert(filtfilt(d.Numerator, 1, ts)));

% Compute the WTs of the envelope and the LFP
env_wt = twt(env, EEG.srate, linear_scale(ap.freqs, EEG.srate), ap.wnumber);
lfp_wt = twt(ts, EEG.srate, linear_scale(ap.freqs, EEG.srate), ap.wnumber);

nfreqs = length(ap.freqs);

fh = sync_fh(ap.atype);

% The sync value for the raw time series
for i=1:nfreqs
    sync(i) = fh(env_wt(i,:), lfp_wt(i,:));
end

% Plot it
if doplot
    h = figure(1);
    fname = sprintf('ENVLFP %s %s %s %d %d-%d Hz env', upper(ptname), upper(cond),...
        upper(ap.atype), ch,envfrange(1), envfrange(2));
    set(h, 'Name', fname);
    if surr
        subplot(2,1,1);
    end;


    % PLot the abs of sync as for the momement no interested in -ve
    % correlations or directionality of sync
    plot(ap.freqs, abs(sync));
    if ~isempty(ap.yaxis)
        axis([ap.freqs(1) ap.freqs(end) ap.yaxis]);
    else
        axis([ap.freqs(1) ap.freqs(end) min(abs(sync)) max(abs(sync))]);
    end
    xlabel('Frequency (Hz)');
    ylabel(sprintf('%s', upper(ap.atype)));
end    


% If surrogate testing is requested
if surr
    % Make the surrogates
    for i=1:ap.nsurr
        if ap.scramble_phase
            surr_ts(:,i) = scramble_phase(env);
        else
            surr_ts(:,i) = rand_rotate(env);
        end
    end
   
    % Compute the surrogate syncs
    srate = EEG.srate;
    freqs = ap.freqs;
    wnumber = ap.wnumber;
    
    tic
    parfor i=1:ap.nsurr
        wt = twt(surr_ts(:,i), srate, linear_scale(freqs, srate), wnumber);
        surr_sync(:,i) = fh(wt, lfp_wt);
    end
    toc
    
    for i=1:nfreqs
        counts(i) = length(find(abs(surr_sync(i,:)) > abs(sync(i))));
    end

    p = (counts+1)/(ap.nsurr + 1);
    sig = fdr_vector(p, ap.alpha, ap.fdr_stringent);
    
    if doplot
        subplot(2,1,2);
        plot(ap.freqs, sig);
        axis([ap.freqs(1) ap.freqs(end) 0 1]);
        xlabel('Frequency (Hz)');
        ylabel('Sig');
    end
    
    save_figure(h, get_export_path_SMA(), fname);
    
end





% % Compute the phase difference
% pdiff = phase_diff(angle(henv) - angle(hlfp));
% 
% h = figure(1);
% rose(pdiff);
% 
% mean_phase = angle(sum(exp(1i*pdiff)));
% fprintf('\nMean phase = %6.2f\n', mean_phase)
% [p, ~] = circ_rtest(pdiff);
% fprintf('\nRayleigh test: p = %e\n', p);
% 
% phist = hist(pdiff,nbins);
% ptest = ones(1,nbins)*(length(pdiff)/nbins);
% 
% [~,pks] = kstest2(phist, ptest);
% fprintf('\n K-S Test: p =%e\n', pks);
% 
% % Sync test
% fh = sync_fh(ap.atype);
% sync = fh(henv, hlfp);
% fprintf('\n %s = %e\n', upper(ap.atype), sync)
% 
% 
% if surr
%     % Do surrigate testing for sync parameter
% %     if ap.scramble_phase
% %         env = scramble_phase(env);
% %     else
% %         env = rand_rotate(env);
% %     end
% end





function [R] = sl_pdmi(x, trange, srate, chlabels, dostats)

% Performs time resolved PAC as per Cohen 2008 "Assessing transient
% cross-frequency coupling in EEG data" J. Neurosci Meth 168:494-499
% Then plot PAC vs PC to look for correlations in the two metrics


if nargin < 5; chlabels = {'CH1', 'CH2'}; end;
if nargin < 6; dostats = 0; end;

ap = sl_sync_params();

[nchan, ~] = size(x);

if nchan < 2
    display('Need two channels for this analysis');
    return;
end

T = (0:(length(x)-1))/srate;
tindex = find(T >= trange(1) & T <= trange(2));
X = x(:,tindex); % Just use a subregion of the data
t = T(tindex);
nfreq = length(ap.trpac.wt_lfrange);

% Compute emvelopes for the high-frequency activity
parfor i=1:nchan
    env_hf(:, i) = envelope(X(i,:), ap.trpac.hfrange, srate);
end

% Compute the lfp wavelet transforms
for i=1:nchan
    lfp_wt(:,:,i) = twt(X(i,:), srate, linear_scale(ap.trpac.wt_lfrange, srate), ap.trpac.wt_bw);
end

parfor c=1:nchan
    for f = 1:nfreq
        if ~ap.trpac.pdmi_nsurr
            [PDMI(f,c),PHASE(f,c), ~,~]= pdmi(squeeze(lfp_wt(f,:,1)), squeeze(lfp_wt(f,:,2)), env_hf(:,c),...
                ap.trpac.pdmi_bins, ap.trpac.pdmi_nsurr, ap);
        else
            [PDMI(f,c),PHASE(f,c), p(f,c),~]= pdmi(squeeze(lfp_wt(f,:,1)), squeeze(lfp_wt(f,:,2)), env_hf(:,c),...
                ap.trpac.pdmi_bins, ap.trpac.pdmi_nsurr, ap);
        end
                
    end
end

clf;

subplot(3,1,1);
plot(ap.trpac.wt_lfrange,PDMI(:,1), ap.trpac.wt_lfrange,PDMI(:,2));
xlabel('Freqeuncy (Hz)');
ylabel('PDMI');
legend(chlabels);

subplot(3,1,1);
plot(ap.trpac.wt_lfrange,PHASE(:,1), ap.trpac.wt_lfrange,PHASE(:,2));
xlabel('Freqeuncy (Hz)');
ylabel('PDMI');
legend(chlabels);

if ap.trpac.pdmi_nsurr

    subplot(3,1,3);
    plot(ap.trpac.wt_lfrange,p(:,1), ap.trpac.wt_lfrange,p(:,2));
    xlabel('Freqeuncy (Hz)');
    ylabel('p-value');
    legend(chlabels);
end

R.pdmi = PDMI;
R.phase = PHASE;
if ap.trpac.pdmi_nsurr
    R.p = p;
end

function [env] = envelope(x, frange, srate)
d = window_FIR(frange(1), frange(2), srate);
env = abs(hilbert(filtfilt(d.Numerator, 1, x)));

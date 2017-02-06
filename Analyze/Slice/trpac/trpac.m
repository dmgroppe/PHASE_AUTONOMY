function [pac pac_angle] = trpac(x, srate, lfrange, hfrange, ncycles, forder, nsurr, doplot)

% Time resolved PAC motivated by the paper Cohen, M. X. (2008). % "Assessing transient cross-frequency coupling in EEG data." J Neurosci Methods 168(2): 494-9.
% Surrogates are performed using a time shift method identical to Canolty
% 2006
%
% USAGE 
%   x = time series
%   srate - sampling rate
%   lfrange - low freq range ie. [4 8]
%   hfrange - high frequency range ie [60 200]
%   ncycles - number of cycles over which to average the phase coherence
%   nsurr - number of surrogates for bootstrap statistics


% Taufik A Valiante 2014

alpha = 0.01;

if nargin < 6; forder = 1000; end
if nargin < 7; nsurr = 0; end
if nargin < 8; doplot = 0; end;

nfreqs = length(hfrange);

if nfreqs == 2
    % This means it is a freqeuncy range
    % Band pass the data
    lf_filter = window_FIR(lfrange(1), lfrange(2), srate, forder);
    hf_filter = window_FIR(hfrange(1), hfrange(2), srate, forder);
    N{1} = lf_filter.Numerator;
    N{2} = hf_filter.Numerator;
    
    % Filter the data
    parfor i=1:2
       xfilt(i,:) =  filtfilt(N{i}, 1, x);
    end
    
    % Get the hf envelope
    env_amp = abs(hilbert(xfilt(2,:)));
    
    % Hilbert the high freq envelope filtered in the low-freq range
    h_hf_env = hilbert(filtfilt(N{1}, 1, env_amp));
    
    % Compute the phase coherence between the two time series
    [pac pac_angle] = phase_coh(hilbert(xfilt(1,:)), h_hf_env, lfrange, ncycles, srate);

    if doplot
        T=(0:(length(x)-1))/srate;
        title('Time series');
        ax(1) = subplot(3,1,1);
        plot(T,x);
        xlabel('Time (s)');
        ylabel('Whatever units');

        ax(2) = subplot(3,1,2);
        plot(T, pac);
        xlabel('Time (s)');
        ylabel('PAC');

        ax(3) =  subplot(3,1,3);
        plot(T,unwrap(pac_angle));
        linkaxes(ax, 'x');
        xlabel('Time (s)');
        ylabel('PAC - angle');
    end
    
    if nsurr
        npools =  matlabpool('size');
        blocksize = floor(nsurr/npools);
        lfphase = hilbert(xfilt(1,:));
        parfor i=1:npools
            pac_surr(:,:,i) = pc_surr(lfphase, h_hf_env, lfrange, ncycles, srate, blocksize);
            %pac_surr(:,:,i) = pc_surr_aaft(lfphase, env_amp, lfrange, ncycles, srate, blocksize);
        end
        new_nsurr = blocksize*npools;
        rpac_surr = reshape(pac_surr, length(pac),new_nsurr);
        pacs = repmat(pac,1,new_nsurr);
        counts = sum(pacs<rpac_surr,2);
        p = counts/new_nsurr;
        pfdr = fdr_vector(p, alpha, 1);
        sig_ind = find(pfdr == 1);
        
        if doplot
        
            subplot(3,1,2);
            hold on;
            plot(T(sig_ind), pac(sig_ind), '.r');

%             sig_ind = find(p < 0.05);
%             plot(T(sig_ind), pac(sig_ind), '.g');
        end
        
        
        hold off;
        
    end
else
end

function [pc] = pc_surr(h1, h2, lfrange, ncycles, srate, n)

for i=1:n
    h2 = rand_rotate(h2);
    pc(:,i) = phase_coh(h1, h2, lfrange, ncycles, srate);
end

function [pc] = pc_surr_aaft(h1, env, lfrange, ncycles, srate, n)

surr = AAFT(env,n);
d = window_FIR(lfrange(1), lfrange(2), srate,10000);

for i=1:n
    h2 = hilbert(filtfilt(d.Numerator, 1, surr(:,i)));
    pc(:,i) = phase_coh(h1, h2', lfrange, ncycles, srate);
end


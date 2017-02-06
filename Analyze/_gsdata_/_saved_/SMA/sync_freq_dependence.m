function [mean_sync, std_sync, conflim, norm_sync, loom_var] = sync_freq_dependence(EEG, cond, channels, ap)

atype = ap.atype;
usewt = ap.usewt;
freqs = ap.freqs;
ptname = ap.ptname;
surr = ap.surr;
wnumber = ap.wnumber;

[tstart tend] = get_trange(cond, 60, ptname);
tstart = tstart/1000*EEG.srate;
tend = tend/1000*EEG.srate;
loom_var = [];

% Check if a list of pairs was passed or just vector of channels
if min(size(channels)) == 1
    using_pairs = 0;
else
    using_pairs = 1;
end


if ~using_pairs
    % channels contains a vector of channels, not pairs
    nchannel = length(channels);
    nfreqs = length(freqs);

    npairs = nchannel*(nchannel-1)/2;
    norm_sync = zeros(nfreqs, npairs);

    pair_count = 0;
    pairs = zeros(2,npairs);

    for i=1:nchannel
        x = EEG.data(channels(i), tstart:tend);
        if surr
            if ap.scramble_phase
                x = scramble_phase(x);
            else
                % rotate the data set to generate surrogate time series
                x = rand_rotate(x);
            end
        end
        
        if usewt
            %fprintf('\nComputing wavelet transform for channel #%d', i);
            wt = twt(x, EEG.srate, linear_scale(freqs, EEG.srate), wnumber);
            h(:,:,i) = wt';
        else
            %fprintf('\nFiltering channel #%d', i);
            for k = 1:nfreqs-1
                d = window_FIR(freqs(k), freqs(k+1), EEG.srate);
                h(:,k,i) = hilbert(filtfilt(d.Numerator,1,x));
            end
        end
    end
else
    % A list of pairs has been passed to the function
    npairs = length(channels);
    usewt = 1;
    chlist = [];
    % concantenate all the channels
    for i=1:length(channels)
        chlist = [chlist channels(1,i) channels(2,i)];
    end
    
    % find unqiue channels
    uchannels = unique(chlist);
    
    % compute each ones wt
    for i=1:length(uchannels)
        %fprintf('\nComputing wavelet transform for channel #%d', uchannels(i));
        
        x = EEG.data(uchannels(i), tstart:tend);
        if surr
            % rotate the data set to generate surrogate time series
            x = rand_rotate(x);
        end
        wt = twt(x, EEG.srate, linear_scale(freqs, EEG.srate), wnumber);
        h(:,:,i) = wt';
    end
end

% Get the function handle of sync type
fh = sync_fh(atype);

if ~using_pairs
    % Process all potential pairs
    for i=1:nchannel
        for j=i+1:nchannel
            pair_count = pair_count + 1;
            pairs(:,pair_count) = [channels(i), channels(j)];
            if usewt
                N = nfreqs;
            else
                N = nfreqs-1;
            end
            for k=1:N
                norm_sync(k,pair_count) = fh(h(:,k,i)', h(:,k,j)');
                % remove directionality from IC and WPLI
                if ap.absic
                    if strcmp(atype,'ic') || strcmp(atype,'wpli')
                        norm_sync(k,i) = abs(norm_sync(k,i));
                    end
                end
                % Compute the variance using LOOM
                if ap.loom_compute
                    loom_var(k,pair_count) = sync_loom(h(:,k,i)', h(:,k,j)', ap.loom_window, fh);
                end
            end
        end
    end
else
    % iterate over pairs
    for i=1:length(channels)
        % iterate over frequencies
        for k=1:length(freqs)
            %find where in h, each channel's tranform is
            ch_index1 = find(uchannels == channels(1,i));
            ch_index2 = find(uchannels == channels(2,i));
            % compute sync value
            norm_sync(k,i) = fh(h(:,k,ch_index1)', h(:,k,ch_index2)');
            
            % remove directionality from IC and WPLI
            if ap.absic
                if strcmp(atype,'ic') || strcmp(atype,'wpli')
                    norm_sync(k,i) = abs(norm_sync(k,i));
                end
            end
            % Compute the variance using LOOM
            if ap.loom_compute
                loom_var(k,i) = sync_loom(h(:,k,ch_index1)', h(:,k,ch_index2)', ap.loom_window, fh);
            end
        end 
    end
end

if (npairs > 1)
    %subplot(3,1,1);
    mean_sync = mean(norm_sync, 2);
    std_sync = std(norm_sync, 1, 2);
    conflim = std_sync * 1.96/sqrt(npairs);
    %errorbar(freqs(1:end-1), mean_sync, std_sync/sqrt(21));
    %barweb(mean_sync', std_sync');
    
    if ap.plotsync
        figure(1);
        if usewt
            boundedline(freqs, mean_sync, conflim, 'alpha');
            axis([freqs(1) freqs(end) 0 0.5]);
        else
            boundedline(freqs(1:end-1), mean_sync, conflim, 'alpha');
            axis([freqs(1) freqs(end-1) 0 0.5]);
        end
    end

    
%     subplot(3,1,2);
%     p = 1-normcdf(mean_sync, 0, std_sync);
%     [sig, pcut] = fdr_vector(p, 0.05);
%     plot(freqs(1:end-1), p);
%     axis([freqs(1) freqs(end-1) 0 0.5]);
%     
%     h = zeros(1, nfreqs-1);
%     h(p <= 0.05) = 1;
%     subplot(3,1,3);
%     p = 1-normcdf(mean_sync, 0, std_sync);
%     plot(freqs(1:end-1), h);
%     axis([freqs(1) freqs(end-1) 0 1.0]);
    
else
    if ap.plotsync
        figure(1);
        plot(freqs, norm_sync);
        axis([freqs(1) freqs(end) -1 1]);
    end
    mean_sync = [];
    std_sync = [];
    conflim = [];
end
function [r,noise_ratio, raw] = Szprec_simulation1(scfg, cfg, doplot)

% Simulates multichannel computation of the precusor.  Channel "noise" is
% simulated with a Ornstein–Uhlenbeck process (effectively a 1/f noise
% process).  Either a chirp or additive noise serves as the sdditional
% signal to the a single channel of activity.  By smoothing the segment
% where the noise is to be added, baseline flattening is simulated.

if nargin < 1; scfg = cfg_sim(); end;
if nargin < 2; cfg = cfg_default(); end;
if nargin < 3; doplot = 0; end


srate = scfg.srate;
sim_time = scfg.sim_time;
npoints = sim_time*srate;
nchan = scfg.nchan;

chirp_start = scfg.chirp_start;
chirp_length = scfg.chirp_length;
chirp_freq = scfg.chirp_freq;
lvf_chan = scfg.lvf_chan;
noise_var = scfg.noise_var;
chirp_amp = scfg.chirp_amp;
flat_freq = scfg.flat_freq;

T = (0:(npoints-1))/srate;
pt_ind = find(T <= (sim_time-1));
pt = T(pt_ind); % remove the last second due to edge effects etc

filter_order = srate;
hpf = filter_highpass(5, srate, filter_order);
%flat_freq = 30; % in Hz the frequency below which are attenuated - to simulate baseline flattening
%sm_window = 25;
%make_gamma = false;

% Make some noisy channels
if isempty(scfg.ext_noise)
    y = make_noise(nchan, srate, npoints-1)*noise_var;
else
    y = get_noise(nchan, scfg, npoints);
end

y_chirp = y;

% Get chirp indices
chirp_ind = chirp_start*srate:((chirp_start + chirp_length)*srate-1);

switch scfg.sim_type
    case 'chirp'
        % Make a gamma oscillation - could also make a purely stochastic signal
        %lvf = sin_wave(lvf_freq,10*srate,srate);
        lvf = zap(1, chirp_freq, chirp_length, srate);
        lvf = fliplr(lvf);
        lvf = chirp_amp*lvf;
    case 'noise'
        lvf = one_over_f(chirp_length*srate);
        % Remove the low frequency component (above 60Hz)
        hg_filter = filter_highpass(60, srate, 100);
        lvf = filtfilt(hg_filter.Numerator, 1, lvf);
        lvf = lvf/max(abs(lvf))*chirp_amp*2; % Scale to 1
    case 'osc'
        lvf = sin_wave(scfg.osc_freq, chirp_length*srate, srate, rand*2*pi);
        lvf = lvf*chirp_amp;
end

if flat_freq
    % Perform low pass filtering to simulate flattening of the baseline
    sm_filter = fir1(filter_order, flat_freq/srate/2);
    sm_seg = filtfilt(sm_filter, 1, y(:,lvf_chan)); % Smooth the whole thig t avoid edge effects
    y_chirp(chirp_ind, lvf_chan) = sm_seg(chirp_ind); % Replace the segment with a flattened segment
end

% Combine all the signal together    
lt = (lvf(end)-lvf(1))/length(chirp_ind)*(0:(length(chirp_ind)-1))+lvf(1); % Add a linear trend to remove jumps at the ends
y_chirp(chirp_ind,lvf_chan) = y_chirp(chirp_ind,lvf_chan) + lvf' - lt'; % Add the noise/oscillations

noise_ratio = std(lvf)/std(filtfilt(hpf.Numerator, 1, y(:,lvf_chan)));

% Do the analysis using wavelet analysis
cfg.use_fband = false;

[F, ~] = F_chan_list_1(@Szprec_prec_fun, y, srate, cfg, []);
[F_chirp, ~] = F_chan_list_1(@Szprec_prec_fun, y_chirp, srate, cfg, []);

% compute the ratios
other_chan = setxor(1:nchan, lvf_chan);
f_ratio = squeeze(max(F_chirp./F,[],1));
ratio = mean(f_ratio(chirp_ind,other_chan),2);
r = mean(f_ratio(chirp_ind,lvf_chan))/mean(ratio);
raw = mean(mean(F_chirp(:,chirp_ind, lvf_chan),1));

if doplot
    figure(1);clf;
    set(gcf,'Renderer','zbuffer')
    ax(1) = subplot(5,1,1);
    y_filt = filtfilt(hpf.Numerator, 1, y_chirp(:,lvf_chan));
    plot(pt,y_filt(pt_ind), 'k');
    hold on;
    plot(pt(chirp_ind),y_filt(chirp_ind), 'r');
    plot(pt(chirp_ind),lvf+max(ylim), 'g');
    axis([pt(1), pt(end), -0.1 0.1]);
    title(sprintf('Noise ratio = %6.2f, Noise amp = %6.2f', noise_ratio, chirp_amp));
    hold off;
    set(gca, 'TickDir', 'out');

    ax(2) = subplot(5,1,2);
    p = abs(twt(y_chirp(:,lvf_chan),250,linear_scale(1:100,250),5));
    surf(pt,1:100, zscore(p(:,pt_ind)')');
    view(0,90);
    shading interp;
    caxis([0 3]);
    title('Spectrogram');
    set(gca, 'TickDir', 'out');
    hold on;
    %plot(pt(chirp_ind),lvf+max(ylim)/2, 'w', 'LineWidth', 5);
    hold off;


    %f = squeeze(max(F,[],1));
    f = squeeze(max(F_chirp,[],1));
    ax(3) = subplot(5,1,3);
    imagesc(pt, 1:nchan, f(pt_ind,:)');
    set(gca, 'TickDir', 'out');
    title('Raw Precursor (wavelet)');
    %colorbar;

    ax(4) = subplot(5,1,4);
    imagesc(pt, 1:nchan, f_ratio(pt_ind,:)');
    set(gca, 'TickDir', 'out');
    title('Normalized Precursor');
    %colorbar;
    linkaxes(ax, 'x');  
    
    [~, p] = kstest2(ratio, f_ratio(chirp_ind,lvf_chan));
    title(sprintf('Ratio = %6.2f, p = %6.2e', r,p));
    xlabel('Time (s)');
    ylabel('Channel #');

    % Do analysis using Hilbert
    % The hilbert analysis
    cfg.use_fband = true;
    cfg.fband_forder = 100;
    [f_hilbert, ~] = Sprec_fband(@Szprec_prec_fun, y_chirp, srate, cfg, '', 0, 0);

    ax(5) = subplot(5,1,5);
    imagesc(pt, 1:nchan, f_hilbert(pt_ind,:)');
    set(gca, 'TickDir', 'out');
    title('Raw Precursor (Hilbert)');
    ratio = mean(f_hilbert(chirp_ind,other_chan),2);
    [~, p] = kstest2(ratio, f(chirp_ind,lvf_chan));
    r_hilbert = mean(f_hilbert(chirp_ind,lvf_chan))/mean(ratio);
    title(sprintf('Ratio = %6.2f, p = %6.2e', r_hilbert,p));

    linkaxes(ax, 'x');
    
    figure(2);clf;
    subplot(3,1,1)
    plot(pt,y_filt(pt_ind), 'k');
    axis([pt(1), pt(end), -0.1 0.1]);
    subplot(3,1,2)
    plot(pt(chirp_ind),y_filt(chirp_ind), 'r');
    axis([pt(1), pt(end), -0.1 0.1]);
    subplot(3,1,3)
    plot(pt(chirp_ind),lvf, 'g');
    axis([pt(1), pt(end), -0.1 0.1]);
    title(sprintf('Noise ratio = %6.2f, Noise amp = %6.2f', noise_ratio, chirp_amp));
    hold off;
    set(gca, 'TickDir', 'out');
end

function [y] = make_noise(nchan, srate, npoints)

for i=1:nchan
    %[~, y(:,i)] = orn_uhlen(0,npoints/srate, 1/srate, 0.020);
    y(:,i) = SimulateOrnsteinUhlenbeck(0, 0, .01, 0, 1/srate, npoints);
end

function [y] = get_noise(nchan, cfg, npoints)

[dpoints, dchan] = size(cfg.ext_noise);
tpoints = dpoints - npoints;

for i=1:nchan
    
    ch = ceil(rand*dchan);
    seg = ceil(rand*tpoints);
    
    y(:,i) = cfg.ext_noise(seg:(seg+npoints-1), ch);
end
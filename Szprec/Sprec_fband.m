function [P, rank] = Sprec_fband(Szprec_fun, d, srate, cfg, sdir, doplot, dorank)

if nargin < 5; doplot = 0; end;
if nargin < 6; dorank = 0; end;
[~, nchan] = size(d);

a_cfg = cfg_default();
d = remove_nans(d);

rank = [];

% Band pass filter and hilbert transform
dfilt = window_FIR(cfg.fband(1), cfg.fband(2), srate, cfg.fband_forder);
N = dfilt.Numerator;

parfor i=1:nchan
    xh(:,i) = hilbert(filtfilt(N,1, d(:,i)));
end

% Amplitude envelope calculation
if cfg.fband_use_ampenv
    dfilt = window_FIR(cfg.fband_ampenv_freqs(1), cfg.fband_ampenv_freqs(2), srate, cfg.fband_forder);
    N = dfilt.Numerator;
    parfor i=1:nchan
        xh_env(:,i) = hilbert(filtfilt(N,1,abs(xh(:,i))));
    end
    xh = xh_env;
    clear('xh_env');
end

% Compute th precursor/phase coherence/ values
parfor i=1:nchan-1
    %F{i} = Szprec_fun(xh, i, srate, cfg);
    F{i} = feval(Szprec_fun, xh, i, srate, cfg);
end

% Compute the spatial average
P = zeros(length(d), nchan);
for i=1:nchan
    if i~= nchan
        P(:,i) = sum(F{i},2);
    end
    for j=1:(i-1)
        P(:,i) = P(:,i) + F{j}(:,(i-j));
    end
end
P = P/(nchan-1);
F = P;

% Rank the values
if dorank
    rank = Szprec_rank(F,cfg, a_cfg, sdir);
end

if doplot
    clf;
    T = (0:(length(F)-1))/srate;
    
    ax(1) = subplot(3,1,1);
    imagesc(T,1:nchan, F');
    axis([T(1) T(end) 1 nchan zlim]);
    view(0,90);
    set(gca, 'FontSize', 7);
    title(sprintf('Precursor for frequency range %d-%dHz', cfg.fband(1), cfg.fband(2)));
    xlabel('Time (s)');
    ylabel('Channel number');
    ax_l1 = re_label_yaxis(sdir, cfg, T, nchan);
      
    if dorank
        ax(2) = subplot (3,1,2);
        imagesc(T,1:nchan, rank');
        axis([T(1) T(end) 1 nchan 0 1]);
        set(gca, 'FontSize' , 7);
        view(0,90);
        xlabel('Time (s)');
        ylabel('Channel number');
        title('Rank', 'FontSize', 7);
        ax_l2 = re_label_yaxis(sdir, cfg, T, nchan);
    end
    
    ax(3) = subplot(3,1,3);
    Szprec_tf(d, srate, cfg)
    ax_l3 = re_label_yaxis(sdir, cfg, T, nchan);
    
    linkaxes([ax ax_l1 ax_l2 ax_l3], 'xy');
    axes_text_style();
end






function [R] = channelZoom(pt_name, sz_name, channel, ch_type, freqs, f_freqs, fband)

global DATA_PATH;

% For plotting
global SZPREC_CURR_SZ;
global SZPREC_CURR_WT;
global SZPREC_CURR_T;
global SZPREC_CURR_FREQS;
global PROCESSED_DIR;

if isempty(PROCESSED_DIR)
    PROCESSED_DIR = 'Adaptive deriv';
 end

dfile = fullfile(DATA_PATH, ['\Szprec\' pt_name, '\Data\'], [sz_name '.mat']);

if ~exist(dfile, 'file')
    display(dfile);
    error('Data file not found');
end

if fband
    ffile = fullfile(DATA_PATH, ['\Szprec\' pt_name, '\Processed\'], [sz_name '-F_FBAND' '.mat']);
else
    ffile = make_data_path(sz_name, 'ad');
    %ffile = fullfile(processedPath(sz_name), [sz_name '_F.mat']);
end

if ~exist(ffile, 'file')
    display(dfile);
    error('Data file not found');
end

if nargin < 7; fband = 0; end;
if nargin < 6
    a_cfg = cfg_default();
    f_freqs = a_cfg.freqs;
end

load(dfile);
load(ffile);

% Get the channel labels
[R] = names_from_bi_index(1, pt_name);
if ~isempty(R)
    switch ch_type
        case 'bipolar'
            ch_labels = R.bi_labels;
        case'mono'
            ch_labels = R.bi_labels;
    end
end


% Get the data and the channel labels if they exist
switch ch_type
    case 'bipolar'
        d = matrix_bi(:,channel);
        [npoints, nchan] = size(matrix_bi);
    case'mono'
        d = matrix_mo(:,channel);
        [npoints, nchan] = size(matrix_mo);
end

% Sometimes some NANs can creep in from the export (appear as words or --)
d = remove_nans(d);
d = d-mean(d);
T = (0:(length(d)-1))/Sf;

clf; set(gcf,'Renderer','zbuffer');
set(gcf, 'Name', sprintf('Zoom-%s', sz_name), 'NumberTitle', 'off');

%  PLot the data
ax(1) = subplot(4,1,1);
% Low pass for easier visualization
hpf = filter_highpass(0.5, Sf, 100);
dfilt = filtfilt(hpf.Numerator,1, d);

plot(T,dfilt);
axis([T(1) T(end) min(dfilt), max(dfilt)]);
xlabel('Time(s)');
ylabel('mV');
title(sprintf('Channel %d, %s', channel, ch_labels{channel}), 'FontSize', 12,...
    'FontName', 'Times New Roman');
set(gca, 'TickDir', 'out', 'FontSize', 10, 'FontName', 'Times New Roman');


% PLot the precursor values
if ~fband
    %Plot the raw PA
    ax(2) = subplot(4,1,2);
    f_ind = find(ismember(cfg.freqs, f_freqs) == 1);
    f = squeeze(F(f_ind,:,channel));
    %f_z = zscore(f,[],1);
    f_z = p_norm(f')';

    gen_plot(T,cfg.freqs(f_ind), f, 'Time(s)', 'Frequency(Hz)','Raw - FA', f_freqs);
    caxis([0 0.5]);
else
    f = F(:,channel);
    ax(2)=subplot(4,1,2);
    gen_plot_fband(T,smooth(f,Sf/2),'Time (s)', 'Precursor', 'Raw Precursor value');
end

% Plot z_scored Phase accelration
if ~fband
    ax(3) = subplot(4,1,3);
    gen_plot(T,cfg.freqs(f_ind), f_z, 'Time(s)', 'Frequency(Hz)','Z-FA', f_freqs, [0 1])
else
    ax(3) = subplot(4,1,3);
    gen_plot_fband(T,sqrt(var_windowed(f,Sf/2)),'Time (s)', 'SD', 'Precursor SD');
end


% Spectrogram
wt = twt(d, Sf, linear_scale(freqs, Sf), 5);
a = abs(wt);
z = a./repmat(mean(a,2), 1, length(a));

ax(4) = subplot(4,1,4);
gen_plot(T,freqs,z,'Time(s)', 'Frequency(Hz)','Spectrogram', f_freqs, [0 3])

linkaxes(ax, 'x');

% If there are global variables to save some of this stuff to, do it
if exist('SZPREC_CURR_SZ', 'var')
    SZPREC_CURR_SZ = sz_name;
    SZPREC_CURR_WT = wt;
    SZPREC_CURR_T = T;
    SZPREC_CURR_FREQS = freqs;
end


% Return some pertinent variables

R.wt = wt;  % Wavelet transform
R.f = f;    % Precursor values
R.T = T;    % Time vector
R.Sf = Sf;  % Sampling rate
R.d = d;    % Actual data trace

    

function [] = gen_plot(x,y,z,xl, yl,tit, y_freqs, cax)

if nargin < 9; cax = [0 3]; end;

surf(x,y,z);
axis([x(1), x(end) y(1) y(end) min(min(z)), max(max(z))]);
view(0,90);
shading interp;

if ~isempty(cax)
    caxis(cax);
end
set(gca, 'YScale', 'log', 'YTick', y_freqs, 'FontSize', 7);
ylabel(yl, 'FontSize', 10, 'FontName', 'Times New Roman');
xlabel(xl, 'FontSize', 10, 'FontName', 'Times New Roman');
title(tit, 'FontSize', 10, 'FontName', 'Times New Roman');
set(gca, 'TickDir', 'out', 'FontSize', 10, 'FontName', 'Times New Roman');

function [] = gen_plot_fband(x,y,xl, yl,tit)

plot(x,y);
axis([x(1), x(end) min(y) max(y)]);
ylabel(yl, 'FontSize', 10, 'FontName', 'Times New Roman');
xlabel(xl, 'FontSize', 10, 'FontName', 'Times New Roman');
title(tit, 'FontSize', 10, 'FontName', 'Times New Roman');
set(gca, 'TickDir', 'out', 'FontSize', 10, 'FontName', 'Times New Roman');


    





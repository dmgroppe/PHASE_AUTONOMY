function [mi tf T] = pac_tr(ts, srate, trange, lf, hfrange, events, doplot, nsurr, wnumber)

% USAGE: [mi] = mi_tr(ts, srate, trange, lf, hfrange, events, wnumber)
%
% Computes time resolved PAC motivated by MX Cohen
%
% Input:
%   ts - time series
%   srate - sampling rate
%   trange - time range for computation in ms ie. [-200 1000] relative to
%           the event marker
%   lf -    single low frequency
%   hfrange - range of high frequncy values to compute CFC across
%   events - event markers in samples
%   doplot - plot the results
%   nsurr - number of surrogates to use for significance
%   wnumber - wavelet number for transform
% Output:
%   mi -    Time resolved CFC
%   tf -    Average power spectrum of events
%   T -     Time interval over which mi was computed

% Taufik A Valiante 2013

if nargin < 9; wnumber = 1; end;
if nargin < 8; nsurr = 0; end;
if nargin < 7 ; doplot = 0; end;

alpha = 0.05;

% Create the band pass filter for high-frequency range
d = window_FIR(hfrange(1), hfrange(2), srate, 10000);

N = d.Numerator;
hf_ts = filtfilt(N, 1, ts);

% Normalize the the high frequency time series
hf_amp = abs(hilbert(hf_ts));
hf_wt = twt(hf_amp, srate, linear_scale(lf, srate), wnumber);

lf_wt = twt(ts, srate, linear_scale(lf, srate), wnumber);

% Covert time range to points
prange = fix(trange/1000*srate);

% Get full length of the interval
rlength = sum(abs(prange));

% Compute the phase difference across all frequncies across entire time
% series
for i=1:length(lf)
    R(:,i) = exp(1i*angle(hf_wt(i,:).*conj(lf_wt(i,:))./(abs(hf_wt(i,:)).*abs(lf_wt(i,:)))));
end

% Loop over the events and compute the circular means ie. phase locking
% value

pac = zeros(rlength, length(lf));
lf_plv =zeros(length(lf), rlength);
hf_plv = lf_plv;
lf_erp = lf_plv;
hf_erp = lf_erp;
for i=1:length(events)
    range = events(i)+ prange;
    pac =  pac + R(range(1):(range(2)-1), :);
    lf_plv = lf_plv + exp(1i*angle(lf_wt(:,range(1):(range(2)-1))));
    hf_plv = hf_plv + exp(1i*angle(hf_wt(:,range(1):(range(2)-1))));
    lf_erp = lf_erp + cos(angle(lf_wt(:,range(1):(range(2)-1))));
    hf_erp = hf_erp + cos(angle(hf_wt(:,range(1):(range(2)-1))));
end
nevents = length(events);
mi = abs(pac'/length(events));
lf_plv_amp = abs(lf_plv/nevents);
hf_plv_amp = abs(lf_plv/nevents);
lf_erp = lf_erp/nevents;
hf_erp = hf_erp/nevents;

T = (0:(rlength-1))/srate*1000 + trange(1);

if doplot
    % Plot the results
    h = figure(1);
    set(h,'Name', 'Time resolved PAC');
    clf('reset');
    
    subplot(3,2,1);
    plot_mi(mi, T, lf, [0 1]);
    title('Time resolved PAC');
    
    subplot(3,2,3);
    plot_mi(lf_plv_amp, T, lf, [0 1]);
    title('Low frequncy PLV');
    
    subplot(3,2,5);
    plot_mi(mi - lf_plv_amp, T, lf, [-1 1]);
    title('PAC - LFPLV');
    
    subplot(3,2,2);
    plot_mi(hf_plv_amp, T, lf, [0 1]);
    title('High frequency - PLV');
    
    subplot(3,2,4);
    plot_mi(lf_erp , T, lf);
    title('LF ERP');
    
    subplot(3,2,6);
    plot_mi(hf_erp , T, lf);
    title('HF ERP');
    
    drawnow;
end

% Do surrogate testing for significance
if nsurr
    tic
    parfor j=1:nsurr
        mis = get_full_mi(lf_phase, hf_env, lf, hfrange, prange, events, rlength, true);
        mi_surr_norm = mi_blnorm(mis, T, rlength);
        mi_surr(:,:,j) = mi_surr_norm;
    end
    toc
    pcount = zeros(size(mi));

    for i=1:nsurr
        pcount = pcount + (mi_surr(:,:,i) >= mi_norm);
    end

    h = figure(2);
    clf('reset');
    set(h,'Name', 'P-values');
    pboot = (pcount+1)/(nsurr + 1);
    pbootsig = reshape(fdr_vector(reshape(pboot,1,numel(pboot)),alpha,0),size(pboot));
    if max(max(pbootsig)) ~= 0
        plot_mi(pbootsig.*mi_norm, T, hfrange, [1 5]);
        title('Bootstrapped P-values');
    end
end

%-------------- Support functions ---------------------------------------%

function [mit] = get_mi(lf_phase, hf_env, lfrange, hfrange, prange, i, events, gen_surr)

if nargin < 8; gen_surr = false; end;
nevents = length(events);

if gen_surr
    % Dissociate phase from amplitude through randomization of events
    hf_events = events(randperm(nevents));
else
    hf_events = events;
end

mit = zeros(length(hfrange), length(lfrange));

for j=1:length(lfrange)
    lfphase = lf_phase(j,prange(1)+i+events);
    for k=1:length(hfrange)
        hfenv = hf_env(k,prange(1)+i+hf_events);
        
        % Compute the circular to linear correlation
        mit(k,j) = circ_corrcl(lfphase, hfenv);
        
        % GLM - Regress out the relationship - buggy
%         X = [ones(1, nevents); cos(lfphase); sin(lfphase)]; % cos and sin components of phase
%         [~, ~, ~, ~, stats] = regress(hfenv', X');
%         mit(k,j) = stats(4);
    end
end


% Compute full TR CFC for easy paralellization during surrogate testing
function [mi] = get_full_mi(lf_phase, hf_env, lf, hfrange, prange, events, rlength, gen_surr)
for i=0:(rlength-1)
    mit(:,:,i+1) = get_mi(lf_phase, hf_env, lf, hfrange, prange, i, events, gen_surr);
end
mi = squeeze(mean(mit,2));

% Baseline normalization routine
function mi_norm = mi_blnorm(mi, T, rlength)
bl_ind = find(T <= 0);
if ~isempty(bl_ind)
    bl = mean(mi(:,bl_ind),2);
    mi_norm = mi./repmat(bl,1,rlength);
else
    mi_norm = mi;
end

% Plotting routine
function [] = plot_mi(mi, T, hfrange, zaxis)

if nargin < 4; zaxis = []; end;

set(gcf, 'Renderer', 'zbuffer');
surf(T, hfrange, mi);
axis([T(1) T(end) hfrange(1) hfrange(end) min(min(mi)), max(max(mi))]);
set(gca, 'YScale', 'log', 'YMinorTick', 'on', 'TickDir', 'out');
yvals = get(gca,'YTickLabel');
set(gca,'YTickLabel',  10.^str2num(yvals));

view(0,90);
shading interp;
xlabel('Time (ms)');
ylabel('Frequency (Hz)');
if ~isempty(zaxis)
    caxis(zaxis);
end

colorbar;


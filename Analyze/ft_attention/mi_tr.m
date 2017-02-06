function [mi tf T] = mi_tr(ts, srate, trange, lf, hfrange, events, doplot, nsurr, wnumber)

% USAGE: [mi] = mi_tr(ts, srate, trange, lf, hfrange, events, wnumber)
%
% Computes time resolved cross frequency coupling (aka modulation
% index) motivated by Voytek et al (2013) Neuroimage 64 416-424.
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

if nargin < 9; wnumber = 5; end;
if nargin < 8; nsurr = 0; end;
if nargin < 7 ; doplot = 0; end;

alpha = 0.05;

% Compute the WT for the low frequnecy and get phase.  I use the WT rather than
% Band pass filtering since it is much faster this way.

lfts = twt(ts, srate, linear_scale(lf, srate), wnumber);
lf_phase = angle(lfts);

% WT of high frequncy to get amplitudes
hf_wt = twt(ts, srate, linear_scale(hfrange, srate), wnumber);
hf_env = abs(hf_wt);

% Covert time range to points
prange = fix(trange/1000*srate);

% Get full length of the interval
rlength = sum(abs(prange));

% Compute the CFC
parfor i=0:(rlength-1)
    mit(:,:,i+1) = get_mi(lf_phase, hf_env, lf, hfrange, prange, i, events);
end

mi = squeeze(mean(mit,2));
T = (0:(rlength-1))/srate*1000 + trange(1);

% Normalize to baseline if there it exists (=negative times)
mi_norm = mi_blnorm(mi, T, rlength);

if doplot
    % Plot the results
    h = figure(1);
    set(h,'Name', 'Time resolved modulation index');
    clf('reset');
    subplot(2,1,1);
    title('Modulation index');

    plot_mi(mi_norm, T, hfrange, [0 5]);

    % Compute the TF spectrum as a check
    subplot(2,1,2);
    tf = zeros(length(hfrange),rlength);
    for i=1:length(events)
        tf = tf + hf_env(:,events(i)+prange(1):(events(i)+prange(2)-1));
    end
    
    tf_norm = mi_blnorm(tf, T, rlength);
    plot_mi(tf_norm, T, hfrange, [1 max(max(tf_norm))]);
    title('Average spectrogram');
   
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
        plot_mi(pbootsig, T, hfrange, [0 1]);
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
title('Time resolved CFC');
if ~isempty(zaxis)
    caxis(zaxis);
end

colorbar;


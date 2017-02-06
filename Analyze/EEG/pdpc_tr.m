function [pdpc, T] = pdpc_tr(x1, x2, window, freqs, poverlap, nbins, srate, wnumber, doplot)

% Computes the time resolved pdpc over frange for the the full length of the signals,
% over window (in points) that overlap in percentage by poverlap.

if nargin < 9; doplot = true; end;

nsegs = nsegments(length(x1), window,poverlap);
inds = 1:fix(window*(100-poverlap)/100):length(x1);
ranges = [inds(1:end-2)' inds(1:end-2)'+window-1];
ranges = ranges(1:nsegs,:);
T = (ranges(:,1)-1)/srate;

% check to see if the wavelet transforms have been given, or just the raw
% data

if isreal(x1) && isreal(x2)
    x1_wt = twt(x1,srate,linear_scale(freqs,srate), wnumber);
    x2_wt = twt(x2,srate,linear_scale(freqs,srate), wnumber);
else
    % if they are complex assume they are the wavelet transformed data
    x1_wt = x1;
    x2_wt = x2;
end

tic
parfor i=1:nsegs
    pdpc(:,i) = get_pdpc(x1_wt(:,ranges(i,1):ranges(i,2)),x2_wt(:,ranges(i,1):ranges(i,2)),nbins);
end
toc

if doplot
    h = figure(1);
    set(gcf,'Renderer', 'zbuffer');
    surf(T,freqs,pdpc)
    axis([T(1) T(end) freqs(1) freqs(end) 0 1]);
%     set(gca, 'YScale', 'log', 'YMinorTick', 'on', 'TickDir', 'out');
%     yvals = get(gca,'YTickLabel');
%     set(gca,'YTickLabel',  10.^str2num(yvals));
    caxis([0 max(max(pdpc))]);
    view(0,90);
    shading interp;
    colorbar;
end

function [pdpc] = get_pdpc(wt1,wt2,nbins)

nfreqs = size(wt2,1);

for i=1:nfreqs
    [~, ~, pdpc(:,i), ~, ~, ~] = sync_ppc(wt1(i,:), wt2(i,:), nbins, true);
end

% Just take the PDPC at the good phase bin
pdpc = pdpc(nbins/2+1,:);

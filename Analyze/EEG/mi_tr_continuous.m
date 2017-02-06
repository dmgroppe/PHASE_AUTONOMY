function [mi, T] = mi_tr_continuous(x, window, lfreqs, hfreqs, poverlap, srate, wnumber, nbins, doplot)

% Computes the time resolved pdpc over frange for the the full length of the signals,
% over window (in points) that overlap in percentage by poverlap.

if nargin < 9; doplot = true; end;

nsegs = nsegments(length(x), window,poverlap);
inds = 1:fix(window*(100-poverlap)/100):length(x);
ranges = [inds(1:end-2)' inds(1:end-2)'+window-1];
ranges = ranges(1:nsegs,:);
T = (ranges(:,1)-1+window)/srate;

% check to see if the wavelet transforms have been given, or just the raw
% data

lf_wt = twt(x,srate,linear_scale(lfreqs,srate), wnumber);
lf_phase = angle(lf_wt);
hf_wt = twt(x,srate,linear_scale(hfreqs,srate), wnumber);
hf_env = abs(hf_wt);

tic
parfor i=1:nsegs
    mi(:,:,i) = get_mi(lf_phase(:,ranges(i,1):ranges(i,2)),hf_env(:,ranges(i,1):ranges(i,2)),nbins);
end
toc


if doplot
    set(gcf,'Renderer', 'zbuffer');
    % Average over all the lfreq range so can plot as a time resolved value
    mi_avg = squeeze(mean(mi,2));
    
    % Compute the Z-scored MI
    [mi_z] = z_mi(mi_avg);
    
    ax(1) = subplot(2,1,1);
    surf(T,hfreqs,mi_z);
    axis([T(1) T(end) hfreqs(1) hfreqs(end) 0 max(max(mi_z))]);
    view(0,90);shading interp;   
    %caxis([0 max(max(mi_z))]);
    caxis([0 5]);
    %colorbar;
    xlabel('Time (s)');
    ylabel(sprintf('Z_M_I (%d-%dHz)', min(lfreqs), max(lfreqs)));
    title('Time resolved MI');
    
    % Plot the raw data
    ax(2) = subplot(2,1,2);
    rt = (0:(length(x)-1))/srate;
    plot(rt,x);
    title('Raw data');
    xlabel('Time (s)');
    ylabel('\muV');
    axis([rt(1) rt(end) min(x) max(x)]);
    
    linkaxes(ax, 'x');
end

function [MI] = get_mi(lfphase,hfenv,nbins)

MI = zeros(size(hfenv,1), size(lfphase,1));
for i=1:size(lfphase,1)
    for j = 1:size(hfenv,1)
        [mi, ~, ~] = sync_mi(lfphase(i,:), hfenv(j,:), nbins, 0, false);
        MI(j,i) = mi.tort;
    end
end


function [mi_z] = z_mi(mi)

[~, npoints] = size(mi);

m = mean(mi,2);
s = std(mi,1,2);

mi_z = (mi-repmat(m,1,npoints))./repmat(s,1,npoints);

function [mi phase psig] = sl_mi_grid(data, sr, lfrange, hfrange, dop)

if nargin < 5; dop = false; end;
if nargin < 4; hfrange = 30:100; end;
if nargin < 3; lfrange = 4:20; end;


% data - a vector of sample points
% sr - sampling rate
% lfrange - vector of low freqeuncy values
% hfrange - vector of high frequency values
% dop - do statistical analysis on MI grid

if nargin < 5; dop = 0; end;

ap = sl_sync_params(); % get default parameters
nbins = ap.mi.nbins;
nsurr = ap.mi.nsurr;

ts = data;

% Get low freq phase and high freq amplitude from wavelet transformed data
lf_wt = twt(ts, sr, linear_scale(lfrange, sr), ap.wnumber);
lf_phase = angle(lf_wt);
hf_env = abs(twt(ts, sr, linear_scale(hfrange, sr), ap.wnumber));

% Compute the MI matrix, also get the p-vale at the same time thorugh
% bootstrapping

surr_mi = zeros(length(hfrange), length(lfrange));

parfor i=1:length(lfrange)
    lfphase = lf_phase(i,:);
    [MI(:,i), s_mi] = do_mi(lfphase, hf_env, nbins, nsurr, ap, hfrange, dop);
    
    if ~isempty(s_mi)
        surr_mi(:,i) = s_mi;
    end
    
end

[yfreq, xfreq] = size(MI);
mi = reshape([MI(:,:).tort], yfreq, xfreq);
phase = reshape([MI(:,:).phase], yfreq, xfreq);

% quick plot of the MI
figure(1);clf;
surf(lfrange, hfrange, mi);
shading flat;
axis([lfrange(1) lfrange(end) hfrange(1) hfrange(end) 0 1]);
view(0,90);
xlabel('Hz');
ylabel('Hz');

if dop

    mis = reshape(surr_mi, 1, numel(surr_mi));

    surrogate_mean = mean(mis);
    surrogate_std = std(mis);

    p = 1-normcdf(abs(mi),abs(surrogate_mean),abs(surrogate_std));

    psig = p;
    psig(find(p > ap.mi.alpha)) = 0;
    psig(find(p <= ap.mi.alpha)) = 1;
    

else
    psig = ones(yfreq,xfreq);
end

function [MI surr_mi] = do_mi(lfphase, hf_env, nbins, nsurr, ap, hfrange, dop)
for j= 1:length(hfrange)
    if dop
        [MI(j), ~, surr_mi(j)] = sync_mi(lfphase, hf_env(j,:), nbins, nsurr, 1, ap);
    else
        [MI(j), ~, ~] = sync_mi(lfphase, hf_env(j,:), nbins, nsurr, 0,ap);
    end
    %[MI(j,i), MIp(j,i)] = sl_mnorm(lfphase, hf_env(j,:), sr);
end

if ~dop
    surr_mi = [];
end

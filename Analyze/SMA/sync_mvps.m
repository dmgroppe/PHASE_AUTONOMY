function [p K_fit] = sync_mvps(EEG, channels, frange, cond, ptname, dop)

if nargin < 6; dop = 0; end;

ap = sync_params();
ap.alpha = 0.05;

[tstart tend] = get_trange(cond, ap.length, ptname);
subr = get_subregion(EEG, tstart, tend);
data = subr(channels,:);

ap.sync.lowcut = frange(1);
ap.sync.highcut = frange(2);

phases = angle(hilberts(data, EEG.srate, ap));

figure(1);
plot_phase_dist_nd(phases);

K_fit = fit_model(phases);
abs(K_fit)
angle(K_fit)
hval = max(max(abs(K_fit(:))));

figure(2);
imagesc(abs(K_fit),[-1 1]*hval);
title({'Estimated coupling';'matlab (K\_fit)'});
axis square off;

if dop

    srate = EEG.srate;
    nchan = size(data,1);
    
    tic;
    parfor i=1:ap.nsurr
        surr = d_surr(data, srate,ap);
        K_surr(:,:,i) = fit_model(surr);
    end
    toc;
    
    counts = zeros(nchan, nchan);
    
    for i=1:ap.nsurr
        counts = counts + (abs(K_surr(:,:,i)) > abs(K_fit));
    end
    p = (counts+1)/(ap.nsurr + 1);
    p
%     sig = p < ap.alpha;
%     Ksig = K_fit.*sig;
%     figure (3);
%     axis square on;
%     imagesc(abs(Ksig),[-1 1]*hval);
%     title('Significant coupling');
%     axis square off;
else
    p = [];
end

function [phases] = d_surr(x, srate, ap)

ch = size(x,1);

for i=1:ch
    new_x(i,:) = rand_rotate(x(i,:));
    %new_x(i,:) = scramble_phase(x(i,:));
end

phases = angle(hilberts(new_x, srate, ap));




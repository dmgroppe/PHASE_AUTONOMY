function [pinc] = ms_SMA_bs(z0, ts, srate, window, aparams)

scales = get_scales(aparams, srate);

nsegments = floor(length(ts)/window);
nfrq = length(get_scales(aparams, srate));
nsurr = aparams.ana.nsurr;

% Get the test statistic
pinc = zeros(nfrq, nfrq);
z = zeros(nfrq, nfrq, nsurr);

tic
for i=1:nsurr
    % Get test statistic for each permutation
    fprintf('Surrogate %d of %d\n', i, nsurr);
    z(:,:,i) = get_z(ts, nsegments, srate, window, scales);
end
toc

for i=1:nsurr  
    ind = find(z(:,:,i) > z0);
    pinc(ind) = pinc(ind) + 1;
end
pinc = (1+pinc)./(nsurr+1);

function [ms] = get_z(ts, nsegments, srate, window, scales)

% scramble the phases of the time series
newts = scramble_phase(ts);

% compute the wavelet transform
[wt ~] = twt(newts, srate, scales, 5);

% split it up into window sized segments
wts = zeros(length(scales), window, nsegments);
for i=1:nsegments
    istart = (i-1)*window+1;
    iend = i*window;
    wts(:,:,i) = wt(:,istart:iend);
end

% compute the modulation strength
[~, ms] = cross_freq_mod(wts);


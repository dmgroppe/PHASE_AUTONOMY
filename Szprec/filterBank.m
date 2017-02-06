function [yf yh] = filterBank(d, freqs, srate, forder)

% Columns need to be individual time series

[np nv] = size(d);

% In freqs row 1 are the lower filter value, row 2 upper filter values
nfreqs = size(freqs,2);

% Make the filters
for i=1:nfreqs
    fb(i) = window_FIR(freqs(1,i), freqs(2,i), srate, forder);
end

yf = zeros(nfreqs, np, nv);
yh = yf;

for i=1:nv
    [yf(:,:,i), yh(:,:,i)] = doFiltering(d(:,i), fb);
end


function [yFilt, yHilbert] = doFiltering(v, fb)

nfb = size(fb,2);
yFilt = zeros(nfb,length(v));
parfor i=1:size(fb,2)
    yFilt(i,:) = filtfilt(fb(i).Numerator, 1, v);
end

yHilbert = hilbert(yFilt);


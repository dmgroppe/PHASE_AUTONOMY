function [F, ch_to_process] = F_chan_list(d, srate, cfg, exclude)

% Does all the channels except the ones in the exclude list
% More efficient than the first version of this

if nargin < 4; exclude = []; end;

if ~isfield(cfg, 'wnumber'); cfg.wnumber = 5; end;
if ~isfield(cfg, 'ncycles'); cfg.ncycles = 0; end;

[~, nchan] = size(d);
d = remove_nans(d);

% Exclude the channels
ch_to_process = setxor(1:nchan, exclude);

% Pre-compute all the wavelet transforms
for i=1:length(ch_to_process)
    wt(:,:,i) = twt(d(:,ch_to_process(i)),srate,linear_scale(cfg.freqs, srate), cfg.wnumber);   
end

% This will take alot of memory
parfor i=1:length(ch_to_process)
    F(:,:,i) = prec(wt, i, srate, cfg);
end

function [m] = prec(wt, chan, srate, cfg)

nchan = size(wt,3);

F = zeros(size(wt,1), size(wt,2));
for i=1:nchan
    if i~= chan
        F = F + precursor(wt(:,:,chan), wt(:,:,i), srate, cfg);
    end
end

m = F/(nchan-1);


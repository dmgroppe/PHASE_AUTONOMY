function [P, ch_to_process] = F_chan_list_1(func, d, srate, cfg, exclude)

% Does all the channels except the ones in the exclude list
% Faster than the first version of this but needs lots of memory

if nargin < 5; exclude = []; end;

if ~isfield(cfg, 'wnumber'); cfg.wnumber = 5; end;
if ~isfield(cfg, 'ncycles'); cfg.ncycles = 0; end;

[~, nchan] = size(d);
d = remove_nans(d);

% Exclude the channels
ch_to_process = setxor(1:nchan, exclude);

% Pre-compute all the wavelet transforms.  USe band pass filtering if
% specified.

if cfg.useFilterBank
    wt = filterBank(d, cfg.fband, srate, cfg.fband_forder);
else
    for i=1:length(ch_to_process)
        wt(:,:,i) = twt(d(:,ch_to_process(i)),srate,linear_scale(cfg.freqs, srate), cfg.wnumber);   
    end
end


nchan = length(ch_to_process);
F = cell(1,nchan-1);

% Compute the pairwise precursor - needs lots and lots of memory!!
if cfg.bigmem
    parfor i=1:(nchan-1)
        F{i} = feval(func, wt, i, srate, cfg);
    end
else
    for i=1:(nchan-1)
        F{i} = feval(func, wt, i, srate, cfg);
    end
end


% Compute the spatial average
P = zeros(size(wt,1), size(wt,2), nchan);
for i=1:nchan
    if i~= nchan
        P(:,:,i) = nansum(F{i},3);
    end
    for j=1:(i-1)
        P(:,:,i) = P(:,:,i) + F{j}(:,:,(i-j));
    end
end
P = P/(nchan-1);




function [D] = gapfree_plot(Dir, fn, new_sr, dec, doplot, save_dir)

if nargin < 4; dec = 1; end;
if nargin < 5; doplot = false; end;
if nargin < 6; save_dir = {}; end;


fname = [Dir fn '.abf'];
if ~ exist(fname, 'file')
    if isempty(save_dir)
        display('File does not exist.')
    end
    D = [];
    return;
end

mat_file = [Dir 'gap_free_processed\' fn '.mat'];
from_mat = 0;

if ~exist(mat_file, 'file')

    [d si h] = abfload(fname);

    if h.nOperationMode ~= 3
        if isempty(save_dir)
            display('Not the right type of data to display for this function');
        end
        D = [];
        return;
    end

    sr = fix(1/(si*1e-6));

    if mod(sr, new_sr)
        display('Decimation will not work properly with specified sampling rate');
        return;
    end

    if new_sr ~= sr
        highf = new_sr/5;
        f = window_FIR(1, highf,sr);
        xfilt = filtfilt(f.Numerator, 1, d(:,1));
        ts = xfilt(1:sr/new_sr:end);
    end

    T = (0:length(ts)-1)/new_sr*1e3;
    D.ts = ts;
    D.T = T;
    D.hdr = h;
    D.sr = new_sr;
else
    from_mat = 1;
    load(mat_file);
end

if doplot
    clf;
    plot(D.T(1:dec:end), D.ts(1:dec:end));
    axis([D.T(1), D.T(end) min(D.ts) max(D.ts)]);
    tags_plot(gcf, D.hdr);
end


if ~isempty(save_dir) && ~from_mat
    save([save_dir fn '.mat'], 'D');
end
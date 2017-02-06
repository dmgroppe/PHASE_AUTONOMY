% USAGE sig_stats_get(atype, cond, fband, alpha)

function [Sh] = sig_stats_get(atype, cond, frange, roi, alpha, doabs)

if nargin < 6; doabs = 1; end;
if nargin < 5; alpha = .05; end;

inDirs ={'D:\Projects\Data\Vant\Figures\Super\Other BS\'...
         'D:\Projects\Data\Vant\Figures\I7C6\New IC BS\',...
         'D:\Projects\Data\Vant\Figures\Super\',...
         'D:\Projects\Data\Vant\Figures\I7C6\All BS\',...
         'D:\Projects\Data\Vant\Figures\Super\IC Bootstrap\'...
         'D:\Projects\Data\Vant\Figures\Super\BS 128_156Hz\'};

for i=1:size(inDirs,2);
     
    text = sprintf('%s %4.0f-%4.0fHz %s BS Significance alpha %3.0e Results.mat', upper(cond),...
                frange(1), frange(2), upper(atype), alpha);
    fname = [inDirs{i} text];
    if exist(fname, 'file')
        fprintf('\n%s\n', fname);
        load(fname);
        Sh = sig_stats(pinc, pdec, sync, alpha, roi, doabs);
        return;
    end
end

Sh = [];
fprintf('\n%s\n', fname);
display('This result file does not exist');
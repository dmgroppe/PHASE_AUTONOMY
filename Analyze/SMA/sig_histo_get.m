% USAGE sig_histo_get(atype, cond, fband, alpha)

function [] = sig_histo_get(atype, cond, fband, alpha)

if nargin < 4; alpha = .05; end;

inDirs ={'D:\Projects\Data\Vant\Figures\Super\Other BS\'...
         'D:\Projects\Data\Vant\Figures\I7C6\New IC BS\'};

frange = get_franges(fband);
    
for i=1:size(inDirs,2);
     
    text = sprintf('%s %4.0f-%4.0fHz %s BS Significance alpha %3.0e Results.mat', upper(cond),...
                frange(1), frange(2), upper(atype), alpha);
    fname = [inDirs{i} text];
    if exist(fname, 'file')
        fprintf('\n%s\n', fname);
        load(fname);
        sig_histo(pinc, pdec, sync, alpha, atype, 21, [7 8 15 16 59 60 61]);
        return
    end
end
display('This result file does not exist');
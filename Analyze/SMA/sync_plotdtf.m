function [] = sync_plotdtf(fname, ch_pair, dosave)

if nargin < 3; dosave = 0; end;

Dir = 'D:\Projects\Data\Vant\Info\';

if ~exist([Dir fname '.mat'], 'file')
    display('File does not exist');
    return;
end

load([Dir fname '.mat']);
% DTF.labels
% DTF.locations
% DTF.frequency
% DTF.matrix
% DTF.type
% DTF.isadtf
% DTF.srate

ts1 = squeeze(DTF.matrix(chn(ch_pair{2}), chn(ch_pair{1}), :));
ts2 = squeeze(DTF.matrix(chn(ch_pair{1}), chn(ch_pair{2}), :));

h = figure(10);
text = sprintf('%s %s-%s', fname, ch_pair{1},ch_pair{2});
set(h, 'Name', text);
freqs = DTF.frequency(1):DTF.frequency(2);
plot(freqs, ts1, freqs, ts2);

l1 = sprintf('%s-%s', ch_pair{1}, ch_pair{2});
l2 = sprintf('%s-%s', ch_pair{2}, ch_pair{1});
legend({l1,l2});
xlabel('Frequency');
ylabel('DTF');
title(fname);
set(gca, 'TickDir', 'out');
axis([freqs(1) freqs(end) 0 1]);

if dosave
    save_figure(h, get_export_path_SMA(), text);
end
        
function [n] = chn(ch_number, ptname)

% Get the DTF index for specific channel numbers

if nargin < 2; ptname = 'vant'; end;

switch ptname
    case 'vant'
         switch ch_number
            case 'SMA'
                n = 1;
            case 'FMC1'
                n = 2;
            case  'FMC2'
                n = 3;
            case 'MTG'
                n = 4;
        end
    case 'nourse'
       
end        

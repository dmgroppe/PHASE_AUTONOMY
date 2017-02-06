function [n] = chn(ch_number, ptname)

% Get the DTF index for specific channel numbers

if nargin < 2; ptname = 'vant'; end;

switch ptname
    case 'vant'
        switch ch_number
            case 60 % SMA
                n = 1;
            case 8 % FMC1
                n = 2;
            case 16 % FMC2
                n = 3;
            case 49 % MTG
                n = 4;
        end
    case 'nourse'
        switch ch_number
            case 4
                n = 1;
            case 5
                n = 2;
            case 8
                n = 3;
            case 16
                n = 4;
        end
end
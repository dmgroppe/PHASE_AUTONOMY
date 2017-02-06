function [roi] = roi_get(ptname)

switch lower(ptname)
    case 'vant'
        roi = [7 8 15 16 59 60 61];
    case 'nourse'
        roi = [4 5 6 7 8 12 13 14 15 16];
end
function [frange] = get_franges(fband)

switch fband
    case 'alpha'
        frange = [6 11];
    case 'beta'
        frange = [23 30];
    case 'g1'
        frange = [62 73];
    case 'g2'
        frange = [95 107];
    case 'g3'
        frange = [120 145];
    case 'g4'
        frange = [200 400];
end
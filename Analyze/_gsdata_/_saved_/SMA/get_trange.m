function [tstart tend] = get_trange(cond, length, name)

% defualt to vant for the time being
if nargin < 3; name = 'vant'; end;

switch name
    case 'vant'
        switch cond
            case 'aloud'
                tstart = 330000;
                tend = tstart + length * 1000;
            case 'quiet'
                tstart = 410000;
                tend = tstart + length * 1000;
            case 'rest_eo'
                tstart = 10000;
                tend = tstart + length * 1000;
            case 'rest_ec'
                tstart = 110000;
                tend = tstart + length * 1000;
        end
    case 'nourse'
        switch cond
            case 'aloud'
                tstart = 10000;  % Start at 10 seconds in
                tend = tstart + length * 1000;
            case 'quiet'
                tstart = 96.56*1000 + 10000;
                tend = tstart + length * 1000;
            case 'readto'
                tstart = (96.56 + 75.48)*1000 + 20000;
                tend = tstart + length * 1000;
            case 'rest_eo'
                tstart = (96.56 + 75.48 + 2.5*60)*1000 + 20000;
                tend = tstart + length * 1000;
                
        end
end
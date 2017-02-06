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
    case 'saini'
        switch cond
            case 'aloud'
                % 382s to 530s
                tstart = 390000;
                tend = tstart + length * 1000;
            case 'quiet'
                %555s to 756s
                tstart = 560000;
                tend = tstart + length * 1000;
            case 'rest_eo'
                %14s to 180s
                tstart = 30000;
                tend = tstart + length * 1000;
            case 'rest_ec'
                %180s to 356s
                tstart = 190000;
                tend = tstart + length * 1000;
        end
    case 'rako'
        switch cond
            case 'rest_eo'
                tstart = 1;
                tend = tstart + length * 1000;
            case 'quiet'
                tstart = 70000;
                tend = tstart + length * 1000;
            case 'aloud'
                tstart = 60000+98480;
                tend = tstart + length * 1000;
        end
    case 'somer'
    switch cond
        case 'rest_eo'
            tstart =  335680 + 10000;
            tend = tstart + length * 1000;
        case 'rest_ec'
            tstart = 335680 + 200000;
            tend = tstart + length * 1000;
        case 'quiet'
            tstart = 374560 + 10000;
            tend = tstart + length * 1000;
        case 'aloud'
            tstart =  10000;
            tend = tstart + length * 1000;
    end
    case 'jolly'
    switch cond
        case 'rest_eo'
            tstart =  10000;
            tend = tstart + length * 1000;
        case 'rest_ec'
            tstart = 241280;
            tend = tstart + length * 1000;
        case 'aloud'
            tstart = 482560 + 10000;
            tend = tstart + length * 1000;
        case 'quiet'
            tstart = 482560 + 236220 + 10000;
            tend = tstart + length * 1000;
    end
end
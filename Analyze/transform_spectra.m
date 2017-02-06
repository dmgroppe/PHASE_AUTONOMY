% USAGE:    [t] = transform_spectra(s, atype)
%
%   Return the appropriate summary of the test data:  if 'power' - return
%   mean power, if 'cvar', return the circular variance of set of spectra

function [t] = transform_spectra(s, atype)

if nargin < 3
    aparams = get_default_params();
end

switch atype
    case 'power'
        if (isreal(s))
            t = mean(s,3);
        else
            % Compute power then return mean
            t = mean(abs(s).^2, 3);
        end
    case 'cvar'
        if (isreal(s))
            display('Error in get_spectra - expecting complex spectra for cvar');
            t = mean(s,3);
            return;
        end
        % return the CVAR of the spectra - a single 'spectra'
        % Something scewy happens with this calculation giving large
        % negative circular variances...so
        s = exp(1i*angle(s));
        t = 1-abs(sum(s, 3))/size(s,3);
    case 'plstats'
        [t,~] = compute_pl(s, aparams);
        % Need to add computations here
end
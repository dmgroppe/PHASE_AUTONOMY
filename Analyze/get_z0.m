% USAGE: [z0] = get_z0(R1, R2, atype, norm)
%
% Given two sets of spectra type return z0 for bootstrapping stats
%
% Input:
%       R1 - raw spectra
%       R2 - raw spectra
%       atype - refers to the type of analysis.  Can be 'power' or 'cvar'
%
%       norm - type of normalization

function [z0] = get_z0(R1, R2, norm, atype, blsamples)

switch atype
    case 'power'
        r1 = mean(R1, 3);
        r2 = mean(R2, 3);
    case 'cvar'
        r1 = abs(sum(R1, 3));
        r2 = abs(sum(R2, 3));
    case 'plstats'
        % Need to add computations here
end

switch norm
    case 'zero_mean'
        z0 = r1 - mean(mean(r1)) - (r2 - mean(mean(r2)));
    case 'baseline'
        z0 = norm_to_bl(r1,blsamples) - norm_to_bl(r2, blsamples);
    otherwise
        z0 = r1 - r2;
end

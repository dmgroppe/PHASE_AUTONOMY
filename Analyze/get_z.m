% USAGE: [z0] = get_z(R1, R2, atype, norm)
%
% Given two sets of spectra type return z0 for bootstrapping stats
%
% Input:
%       R1 - raw spectra
%       R2 - raw spectra
%       atype - refers to the type of analysis.  Can be 'power' or 'cvar'
%
%       norm - type of normalization

function [z, r1, r2] = get_z(R1, R2, norm, atype, blsamples)

switch atype
    case 'power'
        if (~isreal(R1)); R1 = abs(R1).^2; end
        if (~isreal(R2)); R2 = abs(R2).^2; end
        r1 = mean(R1, 3);
        r2 = mean(R2, 3);
    case 'cvar'
        % Below is a work around when using abs(sum(z)) some very negative
        % cvar values are obtained.
        
        s = exp(1i*angle(R1));
        r1 = 1-abs(sum(s, 3))/size(s,3);
        
        s = exp(1i*angle(R2));
        r2 = 1-abs(sum(s, 3))/size(s,3);
    case 'plstats'
        % Need to add computations here
end

[~, npoints] = size(r1);

% No normalization if CVAR calculation

% All that is below is to preserve r1, and r2, and these are the primary
% number of interest.  The function however modifies the values to return
% the test statistic

switch atype
    case 'cvar'
        % For cvar use the mean resultant length
        z1 = 1-r1;
        z2 = 1-r2;
    otherwise
        z1 = r1;
        z2 = r2;
end

switch norm
    case 'zero_mean'
        z1 = z1 - mean(mean(z1));
        z2 = z2 - mean(mean(z2));
    case 'norm_baseline'
        z1 = norm_to_bl(z1,blsamples);
        z2 = norm_to_bl(z2, blsamples);
    case 'sub_baseline'
        z1 = z1 - repmat(mean(z1(:,1:blsamples),2), 1, npoints);
        z2 = z2 - repmat(mean(z2(:,1:blsamples),2), 1, npoints);
end

z = z1-z2;
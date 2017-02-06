function [P] = pairs_all_types(ptname)

if nargin < 1; ptname = 'vant'; end;

switch lower(ptname)
    case 'vant'

        P.all = pairs_all([1:22,24:31,33:64]);
        P.inside = pairs_get('inside', ptname);
        P.outside = pairs_get('outside', ptname);
        P.local = pairs_get('local', 'vant', vant_scheme());
        P.notlocal = pairs_comb(P.outside, P.local, 'setxor');
        P.local_notinside = pairs_comb(P.local, pairs_all([7 8 15 16]), 'setxor');
        P.notlocal_notinside = pairs_comb(P.notlocal, pairs_all([7 8 15 16]), 'setxor');
        P.notlocal_notinside = pairs_comb(P.notlocal_notinside, pairs_all([59 60 61]), 'setxor');
        
        % Those within NET , and between NET and TL, NOT within TL
        p_net_tl = pairs_2rois([7 8 15 16 59 60 61], [45:50,1,2]);
        P.net_to_tl = pairs_comb(P.inside, p_net_tl, 'union');
        P.fmc_sma = pairs_2rois([7 8 15 16], [59 60 61]);

        % Between temporal lobe and FMC_SMA network
        P.smafmc_tl = pairs_2rois([7 8 15 16 59 60 61],[45 46 47 48 49 50 1 2]);
    case 'nourse'
        P.all = pairs_get('all', ptname);
        P.inside = pairs_get('inside', ptname);
        P.outside = pairs_get('outside', ptname);
        P.local = pairs_get('local', ptname, nourse_scheme());
        P.notlocal = pairs_comb(P.outside, P.local, 'setxor');
        P.notlocal_notinside = pairs_comb(P.local, pairs_all([4 5 6 7 8 12 13 14 15 16]), 'setxor');
end

% Non local pairs, only within the same strip or grid
% that are as well not inside the ROI - this does not include long range
% connection only those that are greater than one centimeter constrained by
% the fact that they are in the same strip.  This ensures that any contacts
% that are not on the same strip, but overlap, are not included in the
% calculation.
p_local_inside = pairs_comb(P.local, P.inside, 'intersect');
P.semilocal_notinside =  pairs_comb(P.local, p_local_inside, 'setxor');
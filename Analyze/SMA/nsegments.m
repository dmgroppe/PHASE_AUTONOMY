function [nseg] = nsegments(full_length, wlength, overlap)

if nargin < 3; overlap = 0; end;
    
nseg = fix((full_length-wlength)/(wlength*(1-overlap/100)));
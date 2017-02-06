function [r, t] = tlimits(span, dlength, srate, poverlap)

% compute the time ranges for specfied window length, no overlap

if nargin < 4; poverlap = 0; end;

inc = fix((100-poverlap)/100*span);
if ~inc
    inc = 1;
end

tlimits = 1:inc:dlength;

r = [(tlimits(1:end-1))' (tlimits(2:end))'-1];
t = (tlimits(1:end-1)-1)/srate;


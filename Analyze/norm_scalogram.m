function [norm_scal] = norm_scalogram(wt, scales)

[nfreq npoints] = size(wt);

if (nfreq ~= length(scales))
    norm_scal = 0;
    return;
end

% caluclate the power
norm_scal = abs(wt).^2;

for i=1:npoints;
    norm_scal(:,i) = norm_scal(:,i)./scales';
end
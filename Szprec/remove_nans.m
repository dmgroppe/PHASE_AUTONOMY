function [m] =remove_nans(m)
ind = find(isnan(m) == 1);
if ~isempty(ind)
    % if the entire array are nan's then set to zero
    if length(ind) == length(m)
        m = 0;
    else
        % Set them to the average
        m(ind) = nanmean(nanmean(m));
    end
end
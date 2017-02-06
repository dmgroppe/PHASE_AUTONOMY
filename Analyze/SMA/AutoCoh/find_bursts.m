function [ranges all_ranges] = find_bursts(Z,bsize,useall)
% Get the bursts which are defines as existing between two local minima,
% and of 
nfreqs = size(Z,1);

for i=1:nfreqs
    [~, min_locs] = findpeaks(-Z(i,:));
    r = [min_locs(1:end-1)' min_locs(2:end)']';
    % Keep all the ranges whether large enough or not
    all_ranges{i} = r;
    ex = [];
    for j=1:size(r,2)
        if max(Z(i,r(1,j):r(2,j))) < bsize
            ex = [ex j];
        end
    end
    if ~isempty(ex)
        r(:,ex) = [];
    end
    ranges{i} = r;
end

if useall
    ranges = all_ranges;
end
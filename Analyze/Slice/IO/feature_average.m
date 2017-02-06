function [M N V] = feature_average(all_features, nspikes, features)
% Gets the mean, std, and number of points stats for all the specified features

feat_col = numel(features)+1;

% Get all the data for the different spike numbers
for i=1:nspikes
    sp{i} = find(all_features(:,feat_col) == i);
end
sp{nspikes+1} = find(all_features(:,feat_col) > nspikes);

for i=1:nspikes+1
    for j=1:numel(features)
        if ~isempty(sp{i})
            M(i,j) = nanmean(all_features(sp{i},j));
            N(i,j) = length(sp{i});
            V(i,j) = std(all_features(sp{i},j))/sqrt(length(sp{i}));
        else
            M(i,j) = 0;
            N(i,j) = 0;
            V(i,j) = 0;
        end
    end
end

function [pairs] = pairs_all(channels)

count = 0;
channels = sort(channels,'ascend');
for i=1:length(channels)
    for j=i+1:length(channels);
        count = count + 1;
        pairs(:,count) = [channels(i), channels(j)];
    end
end


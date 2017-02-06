function [newEEG] = sync_make_bipolar(EEG, pairs)

% this only makes sense if the pairs are LOCAL.  If spatially distrbuted
% thsi is difficult to interpret.

newEEG = EEG;
newEEG.data = zeros(size(pairs,2),length(EEG.data));

for i=1:size(pairs,2)
    newEEG.data(i,:) = EEG.data(pairs(1,i),:) - EEG.data(pairs(2,i), :);
end

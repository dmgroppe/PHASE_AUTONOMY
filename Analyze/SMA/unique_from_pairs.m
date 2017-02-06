function [uchannels] = unique_from_pairs(pairs)

chlist = [];
    % concantenate all the channels
for i=1:length(pairs)
    chlist = [chlist pairs(1,i) pairs(2,i)];
end
    
% find unqiue channels
uchannels = unique(chlist);
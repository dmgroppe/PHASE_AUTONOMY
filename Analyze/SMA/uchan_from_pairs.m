function [uchannels] = uchan_from_pairs(c_pairs)

if min(size(c_pairs)) ~= 2
    uchannels = [];
    fprintf('\nPairs not passed to func: uchan_from_pairs');
    return;
end

chlist = [];
% concantenate all the channels
for i=1:length(c_pairs)
    chlist = [chlist c_pairs(1,i) c_pairs(2,i)];
end
    
% find unqiue channels
uchannels = unique(chlist);


function [amps, avgamps, avglengths, counts, lengths] = get_burst_stats(Z, ranges)
% Get the burst features
nfreqs = size(Z,1);

avgamps = zeros(1,nfreqs);
avglengths = avgamps;
counts = avgamps;

for i=1:nfreqs
    if ~isempty(ranges{i})
        counts(i) = size(ranges{i},2);
        % Length in samples of each burst
        lengths{i} = ranges{i}(2,:)- ranges{i}(1,:);

        for j=1:length(lengths{i})
            amps{i}(j) = max(Z(i,ranges{i}(1,j):ranges{i}(2,j)));
        end
        avgamps(i) = mean(amps{i});
        avglengths(i) = mean(lengths{i});
    else
        counts(i) = 0;
        avgamps(i) = 0;
        avglengths(i) = 0;
    end
end
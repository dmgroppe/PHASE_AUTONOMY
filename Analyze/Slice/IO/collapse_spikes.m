function [all_spikes] = collapse_spikes(S, SR)

count = 0;
for i=1:numel(S)
    for j= 1:numel(S{i})
        if ~isempty(S{i}{j})
            for k=1:numel(S{i}{j})
                count = count + 1;
                all_spikes.sp{count} = S{i}{j}{k};
                all_spikes.sp_number(count) = k;
                all_spikes.sr(count) = SR{i}{j}{k};
            end
        end
    end
end
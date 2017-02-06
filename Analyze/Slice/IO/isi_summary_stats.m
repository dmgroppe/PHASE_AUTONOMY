function [s] = isi_summary_stats(sorted_isi)

nmax = 0;
for i=1:numel(sorted_isi)
    if numel(sorted_isi{i}) > nmax
        nmax = numel(sorted_isi{i});
    end
end

for e = 1:numel(sorted_isi)
    for i = 1:numel(sorted_isi{e})
        if ~isempty(sorted_isi{e}{i})
            s(e,i).m = mean(sorted_isi{e}{i});
            s(e,i).std = std(sorted_isi{e}{i});
            s(e,i).n = length(sorted_isi{e}{i});
        else
            s(e,i).m = NaN;
            s(e,i).std = NaN;
            s(e,i).n = NaN;
        end
    end
    for i=(numel(sorted_isi{e}))+1:nmax
        s(e,i).m = NaN;
        s(e,i).std = NaN;
        s(e,i).n = NaN;
    end
end
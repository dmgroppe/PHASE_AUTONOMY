function [all_lv, lv_stats] = Lv_collect(R, min_lv)

count = 0;
all_lv = [];
for i=1:numel(R)
    ecount = 0;
    for j=1:numel(R(i).S.lv)
        if R(i).S.lv(j) >= 0
            count = count + 1;
            ecount = ecount + 1;
            all_lv(count,:) = [R(i).S.lv(j) ecount];
        end
    end
end


ep_max = max(all_lv(:,2));

for i=1:ep_max
    ind = find(all_lv(:,2) == i);
    if numel(ind) < min_lv
        % If one of bins is zero then all the rest will be (or likely very
        % close to, so discard them
        break;
    else
        lv_stats(i).m = mean(all_lv(ind,1));
        lv_stats(i).std = std(all_lv(ind,1));
        lv_stats(i).n = numel(ind);
    end
end

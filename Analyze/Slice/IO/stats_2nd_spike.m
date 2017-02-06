function [bigger smaller excl] = stats_2nd_spike(R, alist)

bigger = [];
smaller = [];
same = [];
excl = [];

for i=1:length(alist)
    ind = alist(i);
    for j=numel(R(ind).S.pks):-1:1
        if numel(R(ind).S.pks{j}) >= 2
            if R(ind).S.pks{j}(2) > R(ind).S.pks{j}(1)
                bigger = [bigger R(ind)];
            else
                smaller = [smaller R(ind)];
            end
            break;
        else
            excl = {excl R(ind)};
        end
    end
end
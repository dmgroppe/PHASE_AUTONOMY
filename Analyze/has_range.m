function [ hasrange] = has_range(m)

hasrange = 1;
if (max(max(m)) == min(min(m)))
    hasrange = 0;
    return;
end




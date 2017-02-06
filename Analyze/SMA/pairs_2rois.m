function [p_between] = pairs_2rois(roi1, roi2)

count = 0;
for i=1:length(roi1)
    for j=1:length(roi2)
        count = count + 1;
        p_between(:,count) = [roi1(i), roi2(j)];
    end
end

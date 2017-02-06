function [p] = filter_p(p, minLength, srate)

minPoints = minLength*srate;
p([1 end]) = 0;
dp = diff(p, [], 1);
dInd = [find(dp == 1) find(dp == -1)]';
delta = dInd(2,:)- dInd(1,:);
rInd = find(delta < minPoints);

for i=1:numel(rInd)
    range = (dInd(1,rInd(i))+1):dInd(2,rInd(i));
    p(range) = 0;
end
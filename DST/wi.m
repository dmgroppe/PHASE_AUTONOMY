function [w] = wi(x, n)

% Exponential weighting of simplex for prediction and CCM

nu = size(n,2);

sum = 0;
for i=1:nu
    u(i) = exp(-pdist([x n(:,i)]')/pdist([x,n(:,1)]'));
    if isnan(u(i)) == 1
        u(i) = 1;
    end
    sum = sum + u(i);
end
w = u/sum;


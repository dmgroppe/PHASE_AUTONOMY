function [p] = pval(x, y)

% Computes the p-value between two vectors x and y using ranksum.  If y is
% empty it tests if the median of x is not zero using the signtest.

if nargin < 2; y = []; end;

x(find(isnan(x) == 1)) = [];
if ~isempty(x)
    if ~isempty(y)
        y(find(isnan(y) == 1)) = [];
        if ~isempty(y)
            [~,p] = kstest2(x, y);
        else
            p = NaN;
        end
    else
        p = signtest(x);
    end
else
    p = NaN;
end
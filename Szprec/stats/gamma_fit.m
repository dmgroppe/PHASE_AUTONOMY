function [phat, xfit, yfit] = gamma_fit(f)

y = reshape(f,1,numel(f));

phat = gamfit(y);
xfit = linspace(min(xout), max(xout),npoints);
yfit = gampdf(xfit,phat(1),phat(2));

py = 1-gamcdf(y,phat(1), phat(2));
fdr_py = fdr_vector(py, 0.01,1);
p = reshape(fdr_py,size(f));





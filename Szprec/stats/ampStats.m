function [p pcut, pfit] = ampStats(f, alpha, stringent, dist)

y = reshape(f,1,numel(f));
% nzy = y;
% nzy(find(y == 0)) = [];
% nzy = log(nzy);
% [mu sigma] = normfit(nzy);

if nargin < 4; dist = 'norm'; end;

nzy = y;
nzy(find(y == 0)) = [];
[n,xout] = hist(nzy,1000);

switch dist
    case 'norm'
        [mu sigma] = normfit(nzy);
        py = 1-normcdf(y,mu, sigma);
        yfit = normpdf(xout,mu,sigma);
    case 'gamma'
%         phat = gamfit(nzy);
%         py = 1-gamcdf(y,phat(1), phat(2));
%         yfit = gampdf(xout,phat(1),phat(2));
        mu = expfit(nzy);
        py = 1-expcdf(y,mu);
        yfit = exppdf(xout,mu);
         
end
        
%py = 1-normcdf(log(y),mu, sigma);

py = reshape(py,size(f));
[p pcut] = fdr(py, alpha,stringent);

if nargout == 3
    %[n,xout] = hist(nzy,1000);
    
    yfit = yfit*max(n)/max(yfit);
    pfit.x = xout;
    pfit.y = yfit;
    pfit.n = n;
    
%     bar(xout,n);
%     hold on;
%     plot(pfit.x,pfit.y, 'g');
%     hold off

end
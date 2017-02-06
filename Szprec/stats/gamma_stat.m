function [p pcut, pfit] = gamma_stat(f, alpha, stringent)

y = reshape(f,1,numel(f));
nzy = y;
nzy(find(y == 0)) = [];
nzy = log(nzy);
[mu sigma] =normfit(nzy);

py = 1-normcdf(log(y),mu, sigma);
py = reshape(py,size(f));
[p pcut] = fdr(py, alpha,stringent);

if nargout == 3
    [n,xout] = hist(nzy,1000);
    yfit = normpdf(xout,mu,sigma);
    yfit = yfit*max(n)/max(yfit);
    pfit.x = xout;
    pfit.y = yfit;
    pfit.n = n;
    
    bar(xout,n);
    hold on;
    plot(pfit.x,pfit.y, 'g');
    hold off

end

% y = reshape(f,1,numel(f));
% nzy = y;
% nzy(find(y == 0)) = [];
% phat =gamfit(nzy);
% 
% py = 1-gamcdf(y,phat(1), phat(2));
% py = reshape(py,size(f));
% [p pcut] = fdr(py, alpha,stringent);
% 
% if nargout == 3
%     [n,xout] = hist(nzy,1000);
%     yfit = gampdf(xout,phat(1),phat(2));
%     yfit = yfit*max(n)/max(yfit);
%     pfit.x = xout;
%     pfit.y = yfit;
%     
%     bar(xout,n);
%     hold on;
%     plot(pfit.x,pfit.y, 'g');
%     hold off
% end







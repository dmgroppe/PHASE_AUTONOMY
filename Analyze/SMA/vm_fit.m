function [beta, pfit, ps, error] = vm_fit(x,p,ndist,beta0)


switch ndist
    case 1;
        fit_func = @vm_1;
    case 2;
        fit_func = @vm_2;
    case 3;
        fit_func = @vm_3;
    otherwise;
        fit_func = @vm_1;
end

beta = nlinfit(x,p,fit_func,beta0);
pfit = fit_func(beta,x);
error = sqrt(sum((pfit-p).^2))/length(p);

for i=1:ndist
    index = (i-1)*3 + 1;
    ps(:,i) = vm_1(beta(index:(index+2)),x);
end
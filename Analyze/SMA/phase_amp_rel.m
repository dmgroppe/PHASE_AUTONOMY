function [R] = phase_amp_rel(h1, h2, look, phi, tol)

npoints = length(h1);

dphi = (angle(h1) - angle(h2))/2;
dphi = phase_diff(dphi).*sign(dphi);
a1 = abs(h1);
a2 = abs(h2);

% Search the phases differences that cluster around 'phi'
count = 0;
for i=1:npoints
    if abs(dphi(i)-phi) <= tol
        count = count + 1;
        list(count) = i;
    end
end

prior_count =0;
forward_count = 0;
for i=1:count
    if list(i)-look+1 >= 1
        prior_count = prior_count + 1;

        [rho, pval] = corr(a1(list(i)-look+1:list(i))',a2(list(i)-look+1:list(i))','type','Spearman');
        R.prior_corr.rho(prior_count) = rho;
        R.prior_corr.pval(prior_count) = pval;       
        
        [b, ~, ~] = stats(a1(list(i)-look+1:list(i)), 1:look);
        R.prior_corr.slope1(prior_count) = b(2);
        
        [b, ~, ~] = stats(a2(list(i)-look+1:list(i)), 1:look);
        R.prior_corr.slope2(prior_count) = b(2);
        
    end
    if list(i)+look-1 <= npoints
        forward_count = forward_count + 1;
        [rho, pval] = corr(a1(list(i):list(i)+look-1)',a2(list(i):list(i)+look-1)','type','Spearman');
        R.forward_corr.rho(forward_count) = rho;
        R.forward_corr.pval(forward_count) = pval;
        
        [b, ~, ~] = stats(a1(list(i):list(i)+look-1), 1:look);
        R.forward_corr.slope1(forward_count) = b(2);
        
        [b, ~, ~] = stats(a2(list(i):list(i)+look-1), 1:look);
        R.forward_corr.slope2(forward_count) = b(2);
    end
    
    R.amp1(i) = a1(i);
    R.amp2(i) = a2(i);
end

function [b, stats, yfit] = stats(amp, sync)
X = [ones(size(sync))', sync'];
[b,~,~,~,stats] = regress(amp',X);
yfit = b(1) + b(2)*sync;
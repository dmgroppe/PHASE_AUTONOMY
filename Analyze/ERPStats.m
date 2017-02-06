function [] = ERPStats(R1, R2, alpha, corr)

epochs1 = get_epochs(R1);
[epochs2, nchannel] = get_epochs(R2);

dparams = R1{1}(1).params;
npoints = size(epochs1{1}.data,2);
x = get_x(npoints, dparams.data.srate) - dparams.ana.baseline;

label = sprintf('ERP %s+%s vs. %s+%s', R1{1}(1).params.ana.test(1:end-1),...
        R1{1}(1).params.ana.cond, R2{1}(1).params.ana.test(1:end-1), R2{1}(1).params.ana.cond);
h = figure(1);
set(h, 'Name', label);
clf(h);

arange = [x(1) x(end), -30, 30];
for i=1:nchannel
    subplot(2*nchannel, 1, 2*i-1);
    emean1 = mean(epochs1{i}.data);
    emean2 = mean(epochs2{i}.data);
    plot(x,-emean1, x, -emean2);
    label = sprintf('CH%d %s+%s vs. %s+%s: alpha=%6.4f', R1{1}(i).params.ana.chlist(i), R1{1}(i).params.ana.test(1:end-1),...
        R1{1}(i).params.ana.cond, R2{1}(i).params.ana.test(1:end-1), R2{1}(i).params.ana.cond, alpha);
    title(label);
    ylabel('uV');
    xlabel('Time (ms)');
    axis(arange);
        
    for j=1:npoints;
        [p(j), h(j)] = ranksum(epochs1{i}.data(:,j),epochs2{i}.data(:,j),'alpha',alpha);
    end
    
    if (corr)
        h = correct_pvalue(p, alpha);
    end
    subplot(2*nchannel, 1, 2*i);
    plot(x, h, x, p);
    title(label);
    if (corr)
        ylabel('Sig - corrected');
    else
        ylabel('Sig');
    end
    xlabel('Time (ms)');
    
end
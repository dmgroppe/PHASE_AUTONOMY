function [] = run_5species(npoints)

Y = exam2_5species(npoints, ones(1,5)*.001);
figure(10);clf;
plot(Y(:,10:end)');
r = input('Continue[Y/N]: Y', 's');
if isempty(r)
 r = 'y';
end
if strcmpi(r,'n')
    return;
end
for i=1:5
    d = Y(i,10:end);
    y(i).data = (d-mean(d))/var(d);
    y(i).FText = sprintf('Y%d', i);
end

count = 0;
inds = [];
for i=1:5
    for j=(i+1):5
        if i~= j
            count = count+1;
            [rf(:,count) rb(:,count)] = ccm(y(i), y(j), 'doplot', 1, 'nsurr', 0,...
                'NSeg', 1, 'dim', 2, 'tau', 1, 'Tps', 1:10);
            inds = [inds;[i j]];
        end
    end
end


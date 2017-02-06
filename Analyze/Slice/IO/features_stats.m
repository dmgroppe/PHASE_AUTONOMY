function [h p] = features_stats(all_features,ap)

% Collect all the indices of the spikes
for i=1:ap.io.firstspikestodisp
    sp{i} = find(all_features(:,numel(ap.io.features)+1) == i);
end

sp{ap.io.firstspikestodisp+1} = find(all_features(:,numel(ap.io.features)+1) > ap.io.firstspikestodisp);
alpha = ap.io.alpha/((ap.io.firstspikestodisp+1)*ap.io.firstspikestodisp/2);

for i=1:numel(ap.io.features)
    for j=1:ap.io.firstspikestodisp+1
        for k=j+1:ap.io.firstspikestodisp+1
            x1 = all_features(sp{j},i);
            x2 = all_features(sp{k},i);
            [h(i,j,k),p(i,j,k)] = ttest2(x1,x2, alpha);
        end
    end
end

% Print them out

for i=1:numel(ap.io.features)
    printf('\n %s - SIG --------\n', ap.io.features{i});
    for j=1:ap.io.firstspikestodisp
        display(sprintf('%d ', h(i,j,:)))
    end
end

for i=1:numel(ap.io.features)
    printf('\n %s - P-VALUES --------\n', ap.io.features{i});
    for j=1:ap.io.firstspikestodisp
        display(sprintf('%4.2e  ', h(i,j,:).*p(i,j,:)))
    end
end

display('Counts in each spike category:')
ptext = {'1', '2', '3', '>4'};
for i=1:numel(sp)
    printf('Spike %s: %d', ptext{i}, numel(sp{i}));
end
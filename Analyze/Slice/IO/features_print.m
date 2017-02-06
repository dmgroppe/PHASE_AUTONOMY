function [] = features_print(M,V,N, features)


nfeat = numel(features);
nspikes = size(M,1);

for i=1:numel(size(M,2))
    printf('%s\n', upper(features{i}));
    for j=1:size(M,1)
        
    end
end
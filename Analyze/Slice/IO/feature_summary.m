function [all_features all_spikes] = feature_summary(R, ap)
% Ths is a key function that takes a whole set of results (R) for
% individual cells, and distributes the results into vectorized forms, AND
% very importantly the corresponding spikes are placed in th all_spikes
% cell array.

if numel(R)
    for i=1:numel(R)
        [Fs{i} Sp{i}, SR{i}] = collect_features(R(i));
    end
    all_features = collapse_feature(Fs, ap.io.features, ap.io.normalize);
    all_spikes = collapse_spikes(Sp, SR);   
    %plot_spikes(all_spikes, ap.io.firstspikestodisp)
end
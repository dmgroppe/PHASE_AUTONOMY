function [] = sync_test_compare(EEG, chs, frange, w_sizes, atype)

surrs = [0 0 0 1];
condlist = {'aloud', 'quiet','rest_eo', 'rest_eo'};
cm = colormap('lines');

parfor i=1:numel(condlist)
    [syncs(:,:,i), conflim(:,i)] = sync_test(EEG, condlist{i}, chs, frange, w_sizes, atype, surrs(i), 0);
end

mcolor = {'b', 'm', 'g', 'r'};

h = figure(2);
clf('reset');

for i=1:numel(condlist)
    boundedline(w_sizes, syncs(1,:, i), conflim(:,i), mcolor{i}, 'transparency', 0.5);
end

ymax = max(max(syncs(1,:,:))) + max(max(conflim(1,:,:)));
axis([w_sizes(1) w_sizes(end) 0 ymax]);
xlabel('Window size');
ylabel(sprintf('%s (Normalized sync)', upper(atype)));
fname = sprintf('Sync Test %s', upper(atype));
set(h, 'Name', fname);

save_figure(h, get_export_path_SMA(), fname);








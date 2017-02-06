function [isi_stats, y, ye, n] = isi_summary(R, ap, do_print)

if nargin < 3; do_print = false; end;

% Takes a group of cells and sumarized the ISI statistics
if (numel(R))
    [sorted_isi] = isi_sort(R);
    [isi_stats] = isi_summary_stats(sorted_isi);
    isi_plot_stats(isi_stats, ap);
end

[ep,~] = size(isi_stats);
for i=1:ep
    ind = find([isi_stats(i,:).n] >=ap.io.min_isi);
    if ~isempty(ind)
        y{i} = [isi_stats(i,ind).m];
        n{i} = [isi_stats(i,ind).n];
        ye{i} = [isi_stats(i, ind).std]./[isi_stats(i,ind).n];
    end
end
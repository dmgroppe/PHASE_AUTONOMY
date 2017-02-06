function [R_supra, R_infra, uconds, index_list] = get_mi_list(avg_list)

[~, ap] = excel_read('D:\Projects\Data\Human Recordings\Files for First paper\Spreadsheets\','Carlos Analysis_Reviewed');

R_supra = get_mis(ap, 'D:\Projects\Data\Human Recordings\Analyzed\MI Supra\', 'SUPRA');
R_infra = get_mis(ap, 'D:\Projects\Data\Human Recordings\Analyzed\MI Infra\', 'INFRA');

if numel(R_supra) ~= numel(R_infra)
    display('Different number of elements for layers');
    return;
end

nslices = numel(R_supra);

% Run through the list and collect the indices for the slices

for i = 1:nslices
    fnames{i} = R_supra(i).data_ap.cond.fname(1);
    all_data_aps(i) = R_supra(i).data_ap;
end

count = 0;
for i=1:numel(avg_list)
    ind = find_text(fnames, avg_list(i));
    if ind
        count = count + 1;
        index_list(count) = ind;
    end
end

if numel(index_list) ~= numel(avg_list)
    display('Not all the files specified were found');
    return;
end

[uconds] = unique_condition(all_data_aps);

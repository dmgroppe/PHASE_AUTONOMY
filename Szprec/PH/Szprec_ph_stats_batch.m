function [] = Szprec_ph_stats_batch()

% Processes all the patients in sz-list (which should be the master list of
% relevant seizures for each patient

sz_list = sz_list_load();
if ~isempty(sz_list)
    for i=1:numel(sz_list)
        Szprec_ph_stats(sz_list{i}, 'early');
        Szprec_ph_stats(sz_list{i}, 'max');
    end
end
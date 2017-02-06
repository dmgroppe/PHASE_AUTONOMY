function [list] = szlist(pt_name, sz_list)

% Get the appropriate seizure list for the specified patient

global DATA_DIR
 
if nargin < 2
    szlist_path = fullfile(DATA_DIR, 'Szprec','sz_list.mat');
    if exist(szlist_path, 'file')
        load(szlist_path);
    else
        error('Unable to load sz_list');
    end
end

for i=1:numel(sz_list)
    if strcmpi(strtok(sz_list{i}{1}, '_'), pt_name)
        list = sz_list{i};
        break;
    end
end

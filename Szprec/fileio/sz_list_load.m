function [sz_list] = sz_list_load()

global DATA_DIR;

sz_list = [];

list_name = fullfile(DATA_DIR, 'Szprec', 'sz_list.mat');
if ~exist(list_name, 'file');
    display('Sz list not found');
    return;
end

load(list_name);
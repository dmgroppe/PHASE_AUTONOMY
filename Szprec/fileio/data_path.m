function [dpath] = data_path(pt_name)

global DATA_PATH;
dpath = fullfile(DATA_PATH, 'Szprec',  pt_name, 'Data');
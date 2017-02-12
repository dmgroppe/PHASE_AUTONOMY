function [szlist] = get_szlist(pt_name)
% function [szlist] = get_szlist(pt_name)
%
% Creates a list of the available seizures for a patient
%
% Author: DG

global DATA_DIR

in_path=fullfile(DATA_DIR,'Szprec',pt_name,'Data','*.mat');
psbl_files=dir(in_path);
n_files=length(psbl_files);
szlist=cell(n_files,1);
for a=1:n_files,
    szlist{a}=psbl_files(a).name;
end
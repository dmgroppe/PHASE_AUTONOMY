function [eDir] = get_export_path_SMA()

global COMPUTERNAME;
global DATA_PATH;

eDir = 'D:\Projects\Data\Vant\Figures\';

if (strcmp(COMPUTERNAME, 'SUPER')) || (strcmp(COMPUTERNAME, 'SUPER2'))
    eDir = [eDir 'Super\'];
elseif(strcmp(COMPUTERNAME, 'MINI'))
    if ~isempty(DATA_PATH)
        eDir = [DATA_PATH  'MatLab_Analyses\MINI\'];
    else
        eDir = [];
    end
else
    eDir = [eDir 'I7C6\'];
end
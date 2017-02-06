function [Dir] = DTF_dir(ptname)

% Get the output and input directories for DTF files

switch ptname
    case 'vant'
        Dir = 'D:\Projects\Data\Vant\Info\';
    case 'nourse'
        Dir = 'D:\Projects\Data\Nourse\Info\';
end
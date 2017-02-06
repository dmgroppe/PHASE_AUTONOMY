function [Schematic, list] = load_electrode_schematic(ptname)

if nargin < 1; ptname = 'vant'; end;

switch ptname
    case 'vant'
        load('D:\Projects\Data\Vant\Figures\Manuscript\SchematicA.mat');
    case'nourse'
        load('D:\Projects\Data\Vant\Figures\Manuscript\Nourse Schematic.mat');
end
    
list = electrode_locations(ptname);
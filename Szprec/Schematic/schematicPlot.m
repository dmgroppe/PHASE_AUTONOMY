function [ok] = schematicPlot(pt_name)

%global DATA_PATH; % DG changing all DATA_PATH to DATA_DIR in all functions
global DATA_DIR;

ok = 0;

fname = fullfile(DATA_DIR, 'Szprec', pt_name, 'Szprec_schematic.tif');
if exist(fname, 'file')
    A = imread(fname);

    if ~isempty(A)
        show_schematic(A);
        ok = 1;
    end
else
    display(fname);
    display('File not found.')
end


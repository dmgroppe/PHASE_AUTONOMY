function [ok] = Szprec_schematic(pt_name)

global DATA_PATH;

ok = 0;

fname = fullfile(DATA_PATH, 'Szprec', pt_name, 'Szprec_schematic.tif');
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


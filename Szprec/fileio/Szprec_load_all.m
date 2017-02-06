function [PH, F, D] = Szprec_load_all(sz_name, loadPH)

if nargin <2; loadPH = 1; end;

global DATA_PATH;

pt_name = strtok(sz_name, '_');

fpath = fullfile(DATA_PATH, 'Szprec', pt_name, 'Processed\Adaptive deriv\', [sz_name '_F']);
fname = fullfile(fpath,['Page-Hinkley_early\' sz_name '-PH.mat']);

% Load PH File
if loadPH
    if exist(fname, 'file');
        load(fname);
        PH = R;
    else
        display(fname);
        display('PH File not found.')
        PH = [];
    end
else
        PH = [];
end
    

% Load Precursor file - which also contains the raw data
fname = fullfile(fpath,[sz_name '_F.mat']);
if exist(fname, 'file');
    load(fname);
    D.Sf = Sf;
    if exist('group_end_index', 'var');
        D.group_end_index = group_end_index;
    end
    D.matrix_bi = matrix_bi;
    D.matrix_mo = matrix_mo;
    D.cfg = cfg;
else
    display(fname);
    display('F File not found.')
    F = [];
    D = [];
end

% Load the Data
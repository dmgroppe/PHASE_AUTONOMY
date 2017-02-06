function [fname] = make_data_path(sz_name, type)

global DATA_DIR;
global PROCESSED_DIR;
pt_name = strtok(sz_name, '_');


switch type
    case 'fband'
        subdir1 = 'Bipolar_FBAND';
        subdir2 = [sz_name '_F_FBAND'];
        file_name = [sz_name '_F_FBAND.mat'];
        fname = fullfile(DATA_DIR, 'Szprec', pt_name, 'Processed', subdir1, subdir2, file_name);

    case 'ad'
        subdir1 = PROCESSED_DIR;
        subdir2 = [sz_name '_F'];
        file_name = [sz_name '_F' '.mat'];
        fname = fullfile(DATA_DIR, 'Szprec', pt_name, 'Processed', subdir1, subdir2, file_name);
    case 'fig'
        subdir1 = PROCESSED_DIR;
        subdir2 = [sz_name '_F'];
        file_name = ['All freqs - ' sz_name '.fig'];
        fname = fullfile(DATA_DIR, 'Szprec', pt_name, 'Processed', subdir1, subdir2, file_name);
    case 'sz_times'
        fname = fullfile(DATA_DIR, 'Szprec', pt_name, 'sz_times.mat');
    case 'ph'
        subdir1 = PROCESSED_DIR;
        subdir2 = [sz_name '_F' '\Page-Hinkley_early'];
        file_name = [sz_name '-PH.mat'];
        fname = fullfile(DATA_DIR, 'Szprec', pt_name, 'Processed', subdir1, subdir2, file_name);
    case 'data'
        fname = fullfile(DATA_DIR, 'Szprec', pt_name, 'Data', [sz_name '.mat']);
    case 'text_data'
        fname = fullfile(DATA_DIR, 'Szprec', pt_name, 'Data', [sz_name '.txt']);
%     case 'processed'
%         fname = fullfile(DATA_DIR, 'Szprec', pt_name, 'Processed', PROCESSED_DIR, [sz_name '.txt']);
    case 'processed_dir'
        fname = fullfile(DATA_DIR, 'Szprec', pt_name, 'Processed', PROCESSED_DIR);
end


function [filenames] = data_filenames(pt_name)

global DATA_DIR

dpath = fullfile(DATA_DIR, 'Szprec', pt_name, 'Data', '*.mat');
fnames = dir(dpath);

for i=1:numel(fnames)
    filenames{i} = fnames(i).name(1:end-4);
end




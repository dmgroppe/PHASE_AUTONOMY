function [] = dir_mono_to_bipolar(Dir,  new_group_end_index)

ffile = [fullfile(Dir) '*.mat'];
fnames = dir(ffile);
for i=1:numel(fnames)
    fpath = [fullfile(Dir) fnames(i).name];
    display(sprintf('Working on file %d of %d - %s', i, numel(fnames), fpath))
    load(fpath);
    group_end_index = new_group_end_index;
    matrix_bi =  mono_to_bipolar(matrix_mo, group_end_index);
    save(fpath, 'Sf', 'matrix_mo', 'matrix_bi', 'group_end_index');
end

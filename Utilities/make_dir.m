function [dir] = make_dir(dir)
if ~exist(dir, 'dir')
    mkdir(dir)
end
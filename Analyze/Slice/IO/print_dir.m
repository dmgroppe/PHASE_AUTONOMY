function [] = print_dir(Dir)
f = dir(Dir);
list = {f(:).name};

for i=3:numel(list)
    display(f(i).name);
end
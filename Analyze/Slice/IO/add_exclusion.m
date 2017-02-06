function [list] = add_exclusion(list, fn, desc)

n = numel(list.fn);
list.fn{n+1} = fn;
list.desc{n+1} = desc;
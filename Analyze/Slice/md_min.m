function [md_min]= md_min(a)

dim = length(size(a));

md_min = min(a);

for i=1:dim-1
   md_min = min(md_min);
end
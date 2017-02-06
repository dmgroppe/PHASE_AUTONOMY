function [md_max]= md_max(a)

dim = length(size(a));

md_max = max(a);

for i=1:dim-1
   md_max = max(md_max);
end
function [cm] = cmapMake(ctype, cname, nz, offset)

cmap = cbrewer(ctype, cname, 96);
%cm = cmap;
cm(1:nz,:) = repmat([1 1 1],nz,1);
cm((nz+1):64,:) = cmap((nz+1+offset):(64+offset),:);

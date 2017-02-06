fname = 'D:\Projects\Data\colors\cmap.txt';
fid = fopen(fname);
form = '%s%d,%d,%d,%s';
for i=1:128
    str = fgetl(fid);
    c = textscan(str,form);
    cmap(i,:) = [c{2} c{3} c{4}];
end
fclose(fid);

cm = double(cmap(1:2:128,:))/255;

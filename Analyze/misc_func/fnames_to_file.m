function [] = fnames_to_file(Dir, wc)

if isempty(wc)
    fnames = dir(Dir);
else
    fnames = dir([Dir wc]);
end

fid = fopen([Dir 'filenames.txt'], 'w');
for i=1:numel(fnames)
    fprintf(fid, '%sf\n', fnames(i).name(1:end-4));
end

fclose(fid);

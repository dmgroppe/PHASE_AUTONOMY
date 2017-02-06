function [] = printAbfFileList(Dir)

files = dir(fullfile(Dir, '*.abf'));
outFile = fullfile(Dir, 'filenames.txt');

fid = fopen(outFile, 'wt');
for i=1:numel(files);
    fprintf(fid, '%sf\n', files(i).name(1:end-4))
end
fclose (fid);
    
function [] = zap_run_dir(Dir, fnames)


if nargin < 2
    files = dir([Dir '*.abf']);
    if isempty(files)
        display('No files to process')
        return;
    end
    for i=1:numel(files)
        fnames{i} = files(i).name(1:end-4);
    end
else
    count = 0;
    for i=1:numel(fnames)
        if ~strcmpi(fnames{i}, '')
            count = count + 1;
            fn{count} = fnames{i};
        end
    end
    fnames = fn;
end

h = figure(1);
clf;
eDir = [Dir 'ZapAnalysis\'];
if ~exist(eDir, 'dir')
    mkdir([Dir 'ZapAnalysis']);
end

for i=1:numel(fnames)
    err = zap_load(Dir,fnames{i}, [1 20], [360 20000]);
    if ~err
        ind = find(fnames{i} == '.');
        if ~isempty(ind)
            fnames{i}(ind) = [];
        end
        save_figure(h,eDir,fnames{i});
    end
end





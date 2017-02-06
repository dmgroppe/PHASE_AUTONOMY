function [all_cells alist] = all_cells_collect(paths, exclusions)

global DATA_PATH;

all_cells = [];
for i=1:numel(paths)
    fpath = [DATA_PATH paths{i} '.mat'];
    [list] = load_results(fpath, exclusions{i});
    all_cells = [all_cells list];
end

alist = 1:numel(all_cells);

  
function [list] = load_results(fpath, exclusions)

if ~exist(fpath, 'file')
    error('Unable to load one of the results files');
end

load(fpath);

nfiles = numel(R);

count = 0;
for i=1:nfiles
    if ~find_text(exclusions, R(i).fname);
        count = count + 1;
        list(count) = R(i);
    end
end
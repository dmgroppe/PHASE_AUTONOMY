function [] = abf_directory_process(Dir, new_sr)

files = dir([Dir '*.abf']);

if ~numel(files)
    display('No files to process');
    return;
end


% Process the gap_free data first
result_dir = [Dir 'gap_free_processed\'];
if ~exist(result_dir, 'dir');
    status = mkdir(result_dir);
    if ~status
        display('Something went wrong with making the export directory:');
        display(result_dir);
        return;
    end
end

tic
parfor i=1:numel(files)
    gapfree_plot(Dir, files(i).name(1:end-4), new_sr, 1, false, result_dir);
end
toc

% Process the IO stuff
function [] = spectrogram_group(dap, dosave)

% Compute spectrograms over the entire file specified by the cell array of
% daps passed to the function.

if nargin < 2; dosave = 0; end;

for i=1:numel(dap)
    inc = get_sf_val(dap(i), 'GroupInc');
    if strcmp(inc, 'yes') || isempty(inc)
        [~, path_okay] = check_files(dap(i), '.abf');
        if path_okay
            display(sprintf('Processing record %d of %d', i, numel(dap)));
            ufile_names = unique(dap(i).cond.fname);
            for j=1:numel(ufile_names)
                sl_spectrogram(dap(i), ufile_names{j}, dosave);
            end          
        end
    end
end

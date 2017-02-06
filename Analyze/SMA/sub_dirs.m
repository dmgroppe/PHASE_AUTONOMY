function [dir_names]= sub_dirs(datadirs)

% Get the fullpth of subdirectories in a list of datadirs

count = 0;
for i=1:numel(datadirs)
    contents = dir(datadirs{i});
    for j=1:numel(contents)
        if (contents(j).isdir == 1)
            if ~strcmp(contents(j).name, '.') && ~strcmp(contents(j).name, '..')
                count = count + 1;
                dir_names{count} = [datadirs{i} contents(j).name, '\'];
            end
        end
    end
end
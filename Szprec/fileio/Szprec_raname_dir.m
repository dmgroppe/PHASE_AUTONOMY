function [R] = Szprec_raname_dir(sz_names)

global DATA_PATH;

for i=1:numel(sz_names)
    pt_name = strtok(sz_names{i}, '_');

    old_path = fullfile(DATA_PATH, 'Szprec', pt_name, '\Processed\Adaptive deriv',...
        [sz_names{i} '_F'], 'Page-Hinkleyearly');
    
    new_path = fullfile(DATA_PATH, 'Szprec', pt_name, '\Processed\Adaptive deriv',...
        [sz_names{i} '_F'], 'Page-Hinkley_early');
    
    
   if exist(old_path, 'dir')
       movefile(old_path, new_path);
       if exist(old_path, 'dir')
           rmdir(old_path);
       end
   end
end
        
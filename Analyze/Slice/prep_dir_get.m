function [prep_dir] = prep_dir_get(dDir)

% Function to get the pre-processing directory according to user
% preferences

% Get the user
ud = user_get();

if ~isempty(ud)
    if ud.prep.dir_use && ~isempty(ud.prep.dir)
        prep_dir = ud.prep.dir;
    else
        prep_dir = dDir;
    end
else
    prep_dir = dDir;
end
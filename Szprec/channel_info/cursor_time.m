function [] = cursor_time(sz_name)

% Converts a cursor position in a plot to the actual acquisition time.  The
% data matlab file needs to have the 'date_time' variable preesent

dfile = make_data_path(sz_name, 'data');
if exist(dfile, 'file')
    load(dfile, 'date_time');
    if exist('date_time', 'var')
        p = ginput(1); % Get the cursor position
        dvec = datevec(date_time);
        dvec(6) = dvec(6)+p(1); % add seconds to the start of the file
        display(datestr(datenum(dvec), 'HH:MM:SS yyyy-mmm-dd'));
    else
        display('No date_time variable saved in the MAT file.')
    end
end
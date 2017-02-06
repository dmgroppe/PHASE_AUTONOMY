function [user] = user_get()

global DATAUSER;

user = [];
ud = user_data();

if exist('DATAUSER', 'var')
    for i=1:numel(ud)
        if strcmpi(ud(i).name, DATAUSER);
            user = ud(i);
        end
    end 
end
    
function [val] = user_data_get(var)

% Returns specfied user data

global DATAUSER;

val= [];
ud = user_data();
if exist('DATAUSER', 'var')
    uindex = find_text({ud(:).name}, DATAUSER);
    if uindex 
        switch var
            case 'prepdir'
                val = ud(uindex).prep.dir{1};
            case 'ExportDir'
                val = ud(uindex).ExportDir{1};
        end
    end
end
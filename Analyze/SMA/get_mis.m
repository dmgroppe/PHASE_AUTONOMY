function [R] = get_mis(dap, Dir, type)

% Get the MIs from the files

naps = numel(dap);
count = 0;
for i=1:naps
    inc = get_sf_val(dap(i), 'GroupInc');
    if strcmp(inc, 'yes')
        fname = sprintf('%s %s - PSIG MI', dap(i).cond.fname{1},  upper(type));
        fpath = [Dir fname '.mat'];
        if exist(fpath, 'file');
            count = count + 1;
            load(fpath);
            R(count).id = i;
            R(count).mi = mi;
            %R(count).phase = phase;
            R(count).psig = psig;
            R(count).ap = ap;
            R(count).data_ap = data_ap;
            R(count).dop = dop;
            R(count).X = X;
            R(count).T = T;
        else
            display('File does not exist');
            display(fpath);
        end
    end
end
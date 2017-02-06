function [R, a_dap, a_ap] = pdmi_group(dap, dosave)

done = zeros(1,numel(dap));
a_ap = sl_sync_params();
parfor i=1:numel(dap)
    inc = get_sf_val(dap(i), 'GroupInc');
    if strcmp(inc, 'yes') || isempty(inc)
        [~, path_okay] = check_files(dap(i), '.abf');
        if path_okay
            display(sprintf('Analyzing record %d', i));
            r = pdmi_slice(dap(i), dosave);
            R{i} = r;
            done(i) = 1;
        else
            R{i} = {};
        end
    end
end

count = 0;
for i=1:numel(dap);
    if done(i)
        count = count + 1;
        r_temp{count} = R{i};
        a_dap(count) = dap(i);
    end
end

R = r_temp;

% Save the results
if dosave
    save('D:\Projects\Data\Human tissue\pdmi.mat', 'R', 'dap', 'a_ap');
end
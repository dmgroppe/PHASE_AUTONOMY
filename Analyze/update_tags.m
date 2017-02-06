function [tags] = update_tags(tags, epochs, params, srate)


if (length(epochs) ~= params.ana.nepochs)
    display('Epochs differ between tags and expected number');
    tags = [];
    return;
end

nchan = length(tags)/params.ana.nepochs;

for j=1:nchan
    for i=1:params.ana.nepochs
        index = (j-1)*params.ana.nepochs + i;
        tags{index}.limits(1) = epochs(1,1,i)/srate*1000;
        tags{index}.limits(2) = epochs(1,2,i)/srate*1000;
    end
end
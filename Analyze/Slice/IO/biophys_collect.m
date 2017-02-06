function [values] = biophys_collect(R, fields)

fn = fieldnames(R(1).mp);
for i=1:numel(R)
    c = 0;
    for j=1:numel(fields)
        fval = getfield(R(i).mp,fields{j});
        if isscalar(fval)
            c = c + 1;
            values(i,c) = fval;
        end
    end
end
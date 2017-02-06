function [gc] = global_ic(c, doabs)

if nargin < 2; doabs = 0; end;

nchan = length(c);
gc = 0;
for i=1:nchan
    for j=i+1:nchan
        if (doabs)
            gc = gc + ic_Z(abs(c(j,i)));
        else
            gc = gc + ic_Z(c(j,i));
        end
    end
end

gc = iic_Z(2*gc/(nchan*(nchan-1)));
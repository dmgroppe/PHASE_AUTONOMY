function [bounds] = get_frq_bounds(franges, freq_band)

nranges = length(franges);

for i=1:nranges
    if (strcmp(franges(i).Name, freq_band))
        bounds = [franges(i).lb franges(i).ub];
        return;
    end
end
bounds = [];
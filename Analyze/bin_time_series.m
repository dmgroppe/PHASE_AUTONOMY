function [Binned] = bin_time_series(d, bwidthsamples)

[r NPoints] = size(d);

ntbins = floor(NPoints/bwidthsamples);

if (ntbins*bwidthsamples > NPoints)
    ntbins = ntbins-1;
end

Binned = zeros(1,ntbins);

for i=1:ntbins
    tstart = (i-1)*bwidthsamples + 1;
    tend = tstart + bwidthsamples - 1;
    Binned(1,i) = mean(mean(d(tstart:tend)));
end





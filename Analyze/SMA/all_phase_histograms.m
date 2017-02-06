function [ameans] = all_phase_histograms(EEG, frange, cond)

length = 10;
eDir = 'D:\Projects\Data\Vant\Figures\Phase Histograms\';
dosave = 0;

if (strcmp(cond, 'rest_eo'))
    npeaks = 1;
else
    npeaks = 3;
end

chlist = [7 8 15 16 45 46 47 48 49 50 60 61];
nchan = max(size(chlist));

ncomb = nchan*(nchan-1)/2;
ameans = zeros(ncomb, 4);

count = 0;
for i=1:nchan
    for j=i+1:nchan
        count = count+1;
        as = phase_histogram(EEG, [chlist(i) chlist(j)], frange, cond, length, npeaks, dosave); 
        ameans(count,1) = chlist(i);
        ameans(count,2) = chlist(j);
        ameans(count,3:4) = as;
    end
end

fpath = sprintf('%s%s%4.0f %4.0f.mat', eDir, cond, frange(1), frange(2));
save(fpath, 'ameans');
ameans

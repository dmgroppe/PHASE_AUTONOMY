function [] = plot_mieeg(R, channels, zaxis)

nchan = length(channels);

if fix(sqrt(nchan))^2 == sqrt(nchan)^2
    r = sqrt(nchan);
    c = r;
else
    r = fix(sqrt(nchan));
    c = r + 1;
end

count = 0;
for i=1:r
    for j=1:c
        count = count + 1;
        if count <= nchan
            subplot(r,c,count);
            plot_mi(R{count}.lfrange, R{count}.hfrange, R{count}.mi);
            caxis(zaxis);
            title(sprintf('Channel #%d', channels(count)));
        end      
    end
end
    
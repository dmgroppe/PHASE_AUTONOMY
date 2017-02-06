function [clabels] = channel_labels()


for i=1:32
    clabels{i} = sprintf('GR%d',i);
end

for i=33:36
    clabels{i} = sprintf('OFC%d',i-32);
end

for i=37:40
    clabels{i} = sprintf('FP%d',i-36);
end

for i=41:44
    clabels{i} = sprintf('AIH%d',i-40);
end

for i=45:50
    clabels{i} = sprintf('PTL%d',i-44);
end

for i=51:56
    clabels{i} = sprintf('MIH%d',i-50);
end

for i=57:64
    clabels{i} = sprintf('PIH%d',i-56);
end

clabels{1} = 'ATL1';
clabels{2} = 'ATL2';
clabels{3} = 'ATL3';
clabels{9} = 'ATL9';
clabels{7} = 'FMC7';
clabels{8} = 'FMC8';
clabels{15} = 'FMC15';
clabels{16} = 'FMC16';
clabels{59} = 'SMA59';
clabels{60} = 'SMA60';
clabels{61} = 'SMA61';






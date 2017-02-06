function [seg, T] = get_segment(data, ch, times)

si = data(2,1)-data(1,1);
%sr = 1/si;
indicies = times/si;

seg = data(indicies(1):indicies(2), ch);
T = (0:(length(seg)-1))*si*1000; % Convert to ms
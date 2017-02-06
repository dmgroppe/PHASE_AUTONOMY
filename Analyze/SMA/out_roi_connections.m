function [out_roi_nottl] = out_roi_connections(roi)
load('D:\Projects\Data\Vant\Figures\Super\IC Bootstrap\ALOUD  125- 165Hz IC BS Significance alpha 5e-002 Results.mat');
[outside_roi] = replot_sync(pinc, pdec, sync, 0.05, [], roi);
out_roi_nottl = setxor(outside_roi, [45:50,1,2,3]);
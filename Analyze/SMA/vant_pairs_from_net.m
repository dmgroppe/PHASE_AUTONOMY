function [P] = vant_pairs_from_net(roi)

if nargin < 1; roi = [7 8 15 16 59 60 61]; end;

load('D:\Projects\Data\Vant\Figures\Super\IC Bootstrap\ALOUD  125- 165Hz IC BS Significance alpha 5e-002 Results.mat');
[R Res] = replot_sync(pinc, pdec, sync, 0.05, [0 0.5], roi);
P.TL = [1,2,45:50];
P.FMC = [7 8 15 16];
P.DSN = [7 8 15 16 59 60 61];
P.F = setxor(Res.connected_notinroi, [1 2 3 9 45:50]);
P.SMA = [59 60 61];

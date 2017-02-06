function [mx1 mx2 sem1 sem2] = Ttest(x1, x2)

mx1 = nanmean(x1);
mx2 = nanmean(x2);
sem1 = std(x1)/length(x1);
sem2 = std(x1)/length(x2);

printf('X1: %6.4f +/- %6.4f (%d)', mx1, sem1, length(x1));
printf('X2: %6.4f +/- %6.4f (%d)', mx2, sem2, length(x2));

[p h] = ranksum(x1, x2);
printf('P = %6.4e', p);
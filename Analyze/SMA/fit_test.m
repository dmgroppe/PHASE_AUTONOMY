function [] = fit_test()

x = -pi:0.1:pi;
data = vm_1([.0001, 0, 4], x) + 0.3;

figure(1);
plot(x,data, '.', 'LineStyle', 'None');
sdata = data -0.3;

beta = nlinfit(x,sdata,@vm_1, [1,0,1]);
pfit = vm_1(beta, x)+0.3;
hold on;
plot(x, pfit);

hold off;



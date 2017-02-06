function [] = label_test()

global newLim;

T=(1:100000)/250;
x = sin(T/10);
plot(T,x)
xtick = get(gca, 'XTIck');
for i=1:numel(xtick);
    xtl(:,i) = datevec(datenum(0,0,0,1,1,xtick(i)));
end;

for i=1:numel(xtick)
    xt_label{i} = sprintf('%0d:%0d:%0d', xtl(4,i), xtl(5,i), xtl(6,i));
end

set(gca, 'XTickLabel', xt_label);

h = zoom;
set(h,'ActionPreCallback',@myprecallback);
set(h,'ActionPostCallback',@mypostcallback);
set(h,'Enable','on');
%
function myprecallback(obj,evd)
disp('A zoom is about to occur.');
%
function mypostcallback(obj,evd)
newLim = get(evd.Axes,'XLim');
msgbox(sprintf('The new X-Limits are [%.2f %.2f].',newLim))
xtick = get(gca, 'XTIck')
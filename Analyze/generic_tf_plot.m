function [] = generic_tf_plot(x, y, spec, labels)

set(gcf,'Color','w');
%set(gcf, 'Renderer', 'painters');
surf(x, y, spec);
axis([x(1), x(end), y(1), y(end), min(min(spec)) max(max(spec))]);
view(0,90);
shading interp;
xlabel(labels.x)
ylabel(labels.y)
title(labels.title);
caxis([labels.z.min labels.z.max]);
colorbar;



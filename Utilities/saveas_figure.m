function [] = saveas_figure(h, dir, title, ext)

fullpath = fullfile(char(dir), [char(title) '.' ext]);
saveas(h,fullpath);



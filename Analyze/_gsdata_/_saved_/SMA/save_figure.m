function [] = save_figure(h, dir, title, saveeps)


if nargin < 4; saveeps = 0; end;
fullpath = [dir title];
%print(h, '-dpng', '-painters ', fullpath);

if saveeps
    print(h, '-depsc', '-painters', fullpath);
end
print(h, '-djpeg', '-painters', '-r300', fullpath);


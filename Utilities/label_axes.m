function [] = label_axes(xl, yl, font_name, font_size)

if nargin < 3; font_name = 'Times New Roman'; end;
if nargin <4; font_size = 8; end;

xlabel(xl, 'FontName', font_name, 'FontSize', font_size);
ylabel(yl, 'FontName', font_name, 'FontSize', font_size);


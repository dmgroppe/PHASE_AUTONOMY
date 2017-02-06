function [] = set_fa_prop(ap)


if ~ap.pl.show_axes
    set(gca, 'Visible', 'off');
end

if ap.pl.colorbar
    colorbar;
end
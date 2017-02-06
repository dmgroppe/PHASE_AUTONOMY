function [] = plot_mi(lfrange, hfrange, mi)

ap = sl_sync_params();
%mi = 10*log10(abs(mi));
set(gcf, 'Renderer', 'painters');
surf(lfrange, hfrange, mi);
axis([lfrange(1), lfrange(end),hfrange(1),hfrange(end), min(min(mi)), max(max(mi))]);
axis square;
shading interp;
view(0,90);

if ~isempty(ap.mi.caxis);
    caxis(ap.mi.caxis);
end

%xlabel('Frequency (Hz)', ap.pl.textprop, ap.pl.textpropval);
%ylabel('Frequency (Hz)', ap.pl.textprop, ap.pl.textpropval);
set(gca, ap.pl.textprop, ap.pl.textpropval);
colorbar;
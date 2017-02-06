function [] = light_sz_grid(sz_isi, sz_var, light_isi)

nsz = 1000;
next_sz = 1;
is_corr = 0;

for i=1:length(sz_isi)
    for j=1:length(light_isi)
        [circ_v(i,j), ~] = light_sz_sim(nsz, sz_isi(i), sz_var, ...
            light_isi(j), next_sz, is_corr);
    end
end


surf(light_isi, sz_isi,circ_v);
view(0,90);
shading interp;
ylabel('Seizure ISI (s)');
xlabel('Light ISI (s)');
axis([light_isi(1), light_isi(end) sz_isi(1) sz_isi(end) zlim])
caxis([0,1]);
view(0,90);
colorbar;
title(sprintf('Circular variance using next %d Szs', next_sz));




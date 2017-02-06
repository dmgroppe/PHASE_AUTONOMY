function [] = mod_index_grid(EEG, cond, ch, lowfs, highfs, nfig)

nbin = 18;
alpha = 0.05;
usewt = 1;

[tstart tend] = get_trange(cond, 60);
x = get_ch_subregion(EEG, ch, tstart, tend);

%figure(nfig);
%x = get_sim(length(x), 10, 140, EEG.srate);
%return;

[MI, KS] = mod_index_compute(x, EEG.srate, lowfs, highfs, nbin, 10, usewt);

nlowfs = length(lowfs);
nhighfs = length(highfs);

figure(nfig+1);
surf(lowfs(1:nlowfs), highfs(1:nhighfs), MI);
axis([lowfs(1), lowfs(nlowfs),highfs(1),highfs(nhighfs), min(min(MI)), max(max(MI))]);
shading flat;
view(0,90);

[sig pcut] = fdr(KS.p, alpha);
if max(max(sig)) ~= min(min(sig))
    figure(nfig+2);
    pMI = MI.*sig;
    %pMI = KS.p;
    %pMI = MI.*KS.h;
    surf(lowfs(1:nlowfs), highfs(1:nhighfs), pMI);
    axis([lowfs(1), lowfs(nlowfs),highfs(1),highfs(nhighfs), min(min(pMI)), max(max(pMI))]);
    shading interp;
    view(0,90);
    fprintf('\n Pcut = %6.4f', pcut);
else
    fprintf('\nNo significant values to plot.\n');
end

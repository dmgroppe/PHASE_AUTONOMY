function [] = peak_test(nfig)

file = ['D:\Projects\Data\Scene memory\TVA\Enc\' 'Cu R CH1', '.mat'];

load (file);

[nfreq, npoints, nspectra] = size(spectra);

cvar = abs(sum(spectra,3));

figure(nfig);
ax(1) = subplot(2,1,1);
blsamples = time_to_samples(params.ana.baseline, params.data.srate);

ncvar = norm_to_bl(cvar, blsamples);
%cvar = norm_scalogram(cvar, (1./frq)*params.data.srate);
x = get_x(npoints, params.data.srate);
surf(x, 1:length(frq), ncvar);
view(0,90);
shading interp

%rt = FindRidges(ncvar,frq, 50);
rt = find_peaks(ncvar, 50);
masked = rt.*ncvar;

ax(2) = subplot(2,1,2);
surf(x, 1:length(frq), rt);
view(0,90);
shading interp
linkaxes(ax, 'xy');

reply = input('Enter frequency indices []:');
while (~isempty(reply))
    nridges = length(reply);
    for i=1:nridges
        ridges(i,:) = ncvar(reply(i),:);
       legend_text(i,:) = sprintf('%6.2f',frq(reply(i)));
    end
    figure(nfig+1);
    plot(x,ridges);
    legend(legend_text);
    reply = input('Enter frequency indices []:');
end
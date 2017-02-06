function [] = traces_plot(Dir, fn, ch, epochs)

[hdr, d, si, ap] = io_load(Dir, fn);

if isempty(hdr)
    display('No data loaded')
    return;
end

%sr = 1/(si*1e-6);
T = (si*1e-3)*(0:(hdr.lNumSamplesPerEpisode-1));

h = figure(1);
subplot(2,1,1);
plot(T,squeeze(d(:,ch,epochs)));
xlabel('Time (ms)');
ylabel(hdr.recChUnits{ch});

subplot(2,1,2);
title('Protcol');
pulses = waveform_create(ap, T, size(d,3));

plot(T, pulses(:,epochs));



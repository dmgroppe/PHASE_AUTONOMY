function [] = test_bandwidth()

sr = 500;
npoints = 1000;
wfreq = 4;
nbw = 10;
sample = 500;
x = get_x(npoints, sr);

wave = sin_wave(wfreq, npoints, sr);

scales = linear_scale(1:0.1:10,sr);

for i=1:nbw
    [spectra(:,:,i), freq] = twt(wave, sr, scales, i);
end

power = abs(spectra);
cuts = power(:,sample,:);
cuts = reshape(cuts,length(freq),nbw);

for i=1:nbw
    cuts(:,i) = cuts(:,i)./(scales');
    legend_text{i} = sprintf('BW = %2d', i);
end
plot(freq, cuts);
legend(legend_text);




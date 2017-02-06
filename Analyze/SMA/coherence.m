% USAGE: [coh] = coherence(x1, x2)
function [coh] = coherence(x1, x2)

gpuDevices = gpuDeviceCount;

if (gpuDevices ~= 0)
    x1gpu = gpuArray(x1);
    x2gpu = gpuArray(x2);

    x1fft = fft(x1gpu);
    x2fft = fft(x2gpu);
else
    x1fft = fft(x1);
    x2fft = fft(x2);
end

c = abs(x1fft.*conj(x2fft)./sqrt(x1fft.^2.*x2fft.^2));

if (gpuDevices)
    coh = gather(c);
else
    coh = c;
end
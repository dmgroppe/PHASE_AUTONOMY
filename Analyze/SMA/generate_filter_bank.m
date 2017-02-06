function [fbank] = generate_filter_bank(fstart, steps, fend, fs)

fbank = {};
count = 0;
ntot = floor((fend-fstart)/steps)+1;
for i=fstart:steps:fend
    count = count +1;
    fprintf('Designing %d of %d\n', count, ntot);
    fbank{count} = bpfilter(i-2, i+2, fs);
end
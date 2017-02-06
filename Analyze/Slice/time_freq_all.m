function [] = time_freq_all(ap)

parfor i=1:numel(ap)
    timefreq_full_file(ap(i), ap(i).cond.fname{1} , 1);
end
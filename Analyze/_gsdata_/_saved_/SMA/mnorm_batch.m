function [] = mnorm_batch(EEG)

low_freq_list(:,1) = [4 8];
low_freq_list(:,2) = [9 14];
low_freq_list(:,3) = [15 30];
low_freq_list(:,4) = [.001 32];
low_freq_list(:,5) = [20 25];
low_freq_list(:,6) = [52 63];
low_freq_list(:,7) = [95 107];


high_freq_list(:,1) = [126 166];
high_freq_list(:,2) = [200 400];

ap = sync_params();
ap.alpha = 0.001;

for i=1:size(low_freq_list, 2)
    ap.mnorm.lowf = low_freq_list(:,i);
    for j=1:size(high_freq_list, 2)    
        ap.mnorm.highf = high_freq_list(:,j);
        if max(ap.mnorm.lowf) < max(ap.mnorm.highf);
            mnorm_eeg(EEG, ap, 1);
        end
    end
end








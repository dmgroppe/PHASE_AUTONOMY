function [ae_EEG] = amp_env(EEG, lowcut, highcut, chtoexcl)

[nchan npoints] = size(EEG.data);

ae_EEG = EEG;
ae_EEG.data = zeros(nchan, npoints);
d = window_FIR(lowcut, highcut, EEG.srate);
for i=1:nchan
    if (isempty(find(chtoexcl == i, 1)))
        %ae = abs(hilbert(eegfilt(double(EEG.data(i,:)), EEG.srate, lowcut, highcut)));
        ae = abs(hilbert(filtfilt(d.Numerator,1,EEG.data(i,:))));
        ae = ae-mean(ae);
        ae_EEG.data(i,:) = ae;
    else
        ae_EEG.data(i,:) = EEG.data(i,:);
    end
end
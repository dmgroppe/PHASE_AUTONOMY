%USAGE: sync = sync_matrix(data, aparams)
%
% Computes sync by various methods over the entire duration for all
% combinations of channels - return in sync
%
%   EEG     - EEG struct from eeglab
%   srate   - Hz
%   aparams - options
%   nfig    - figure number
%   type    - type of analysis

function [R h,P] = sync_matrix(data, srate, aparams, type)

[nchan npoints] = size(data);
h = zeros(nchan, npoints);
ap = sync_params();

fprintf('   Filtering and computing hilbert transform\n');

d = window_FIR(aparams.sync.lowcut, aparams.sync.highcut, srate);

 for i=1:nchan
     %filt = eegfilt(double(data(i,:)), srate, aparams.sync.lowcut, aparams.sync.highcut);
     filt = filtfilt(d.Numerator, 1, data(i,:));
     switch type
         case 'acorr'
             h(i,:) = filt;
         otherwise             
            h(i,:) = hilbert(filt);
     end
 end

R = zeros(nchan, nchan);
P = zeros(nchan, nchan);
hj = h;

nbins = aparams.pl.bins;
probbins = aparams.pl.probbins;
steps = aparams.pl.steps;
corrwindow = aparams. corrwindow;
mfreq = mean(ap.frange);

fprintf('   Computing sync matrix\n');

for i=1:nchan
    base = h(i,:);
    parfor j=i+1:nchan
        
        switch type
            case 'pc'
                R(j,i) = phase_coherence(base, hj(j,:));
            case 'pl'
                R(j,i) = pl(base, hj(j,:),nbins, probbins, steps);
            case 'ic'
                R(j,i) = imag_coherence(base, hj(j,:));
            case 'corr'
                R(j,i) = aec(base, hj(j,:));
            case 'acorr'
                R(j,i) = acorr(base, hj(j,:));
            case 'coh'
                R(j,i) = coherence_nogpu(base, hj(j,:));
            case 'pli'
                R(j,i) = pli(base, hj(j,:));
            case 'zph'
                R(j,i) = zero_phase(base, hj(j,:));
            case 'dbswpli'
                R(j,i) = dbswpli(base, hj(j,:));
            case 'wpli'
                R(j,i) = wpli(base, hj(j,:));
            case 'plv'
                R(j,i) = Phase_locking_value(base, hj(j,:));
            case 'spcorr'
                [R(j,i), P(j,i)] = spcorr(base, hj(j,:), corrwindow);
            case 'timed'
                R(j,i) = timed(base, hj(j,:), mfreq);
                
        end
    end
end



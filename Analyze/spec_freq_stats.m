% USAGE: spec_freq_stats((c1, c2, frq, params, ylimits[])
%   Stats along a single frequency band between condition C1 and C2
%
%   Input:
%       c1:         spectra for conditon 1
%       c2:         spectra for conditon 2
%       frq:        array of frequencies
%       params:
%       ylimits[]:  {optional} specify the limits of the yaxis

function [] = spec_freq_stats(c1, c2, frq, params, ylimits)

if (nargin < 5); ylimits = []; end;

[nfrq npoints nspectra] = size(c1);
bl_samples = time_to_samples(params.ana.baseline, params.data.srate);
x = get_x(npoints, params.data.srate);
bwidthsamples = time_to_samples(params.stats.tbin_width, params.data.srate);

reply = input('Enter specific freqeuncy to analyze (Hz): ');

while (~isempty(reply))
    %spec_freq = str2num(reply);
    if (length(reply) == 1)
        fstart = reply;
        fend = reply;
    else
        fstart = reply(1);
        fend = reply(2);
    end
    
    if (min(reply) >= min(frq) && max(reply) <= max(frq))
        
        %findex = get_index(frq, spec_freq);
        %findex = int16(str2num(reply));
        %display(sprintf('Actual frequency = %f', frq(findex)))

        ts{1} = reshape(mean(c1(fstart:fend, :, :),1), npoints, nspectra)';
        ts{2} = reshape(mean(c2(fstart:fend, :, :),1), npoints, nspectra)';
        
        for i=1:nspectra
            b1(i,:) = bin_time_series(ts{1}(i,(bl_samples+1:end)), bwidthsamples);
            b2(i,:) = bin_time_series(ts{2}(i,(bl_samples+1:end)), bwidthsamples);
        end
        
        % Combine the time bins and conditions for permutation ANOVA
        nbins = size(b1, 2);
        for j=1:nspectra
            index = (j-1)*nbins+1;
            M(index:j*nbins) = b1(j,:);
        end
        for j=(nspectra+1):2*nspectra
            index = (j-1)*nbins+1;
            M(index:j*nbins) = b2(j-nspectra, :);
        end
        
        [test,prob,thresh] = perm_anova(M', nspectra, nbins, 2, 1000, .05);
        if (length(reply) == 1)
            result = sprintf('Specific frequency = %6.1f Hz: p = %6.4f', frq(fstart), prob);
        else
            result = sprintf('Specific range = %6.1f-%6.1f Hz: p = %6.4f', frq(fstart), frq(fend), prob);
        end
        
        dplot = [mean(b1);mean(b2)]';
        errors = [std(b1); std(b2)]'/sqrt(nspectra);
    
        if (~(min(min(dplot) == max(max(dplot)))))
            subplot(3,1,1);
            barweb(dplot, errors);
            %bar(dplot', 'group');
            title(result);
            xlabel('Time bin');
            ylabel('Norm to BL');
            if (~isempty(ylim))
                ylim(ylimits)
            end
        end
        
        ymax = max([max(max(b1)) max(max(b2))]);
        ax(1) = subplot(3,1,2);
        bar(b1', 'grouped');
        ylim([0 ymax]);
        ax(2) = subplot(3,1,3);
        bar(b2', 'grouped');
        ylim([0 ymax]);
    else
        display('Frequency is out of range')
    end
    reply = input('Enter specific freqeuncy to analyze (Hz): ');
end










function [spectra] = compute_channel_spectra(asummary, params)

load([params.ana.dataDir params.ana.dataFile]);

spectra = [];

if (~exist('EEG', 'var'))
    display('EEG was not loaded.');
    return;
end

if (length(asummary) > 1)
    display('Cell contains too many channels.');
    return;
end

nepochs = length(asummary.alimit);

if (nepochs <= 0 )
    display('No epochs to display.');
    return;
end

base_line_samples = time_to_samples(params.ana.baseline, EEG.srate);
npoints = asummary.alimit{1}.ep_end - asummary.alimit{1}.ep_start + base_line_samples;

if (npoints <= 0)
    display('Epochs are ill defined.')
    return;
end

nscales = length(get_scales(params, EEG.srate));

spectra = zeros(nscales, npoints, nepochs);

channel = asummary.ch;
display(sprintf('Working on channel #%d', channel));
for i=1:nepochs
    epoch_n = asummary.alimit{i}.ep;
    display(sprintf('Computing spectrum %d of %d, from epoch %d.', i, nepochs, epoch_n))
    
    data_start = asummary.alimit{i}.ep_start-asummary.alimit{i}.prefix;
    data_end = asummary.alimit{i}.ep_end + asummary.alimit{i}.suffix;
    
    % Get the data from the EEG file
    epoch = EEG.data(channel, data_start:data_end);
    
    % zero mean the data
    epoch = epoch-mean(epoch);
            
    % Scramble the phase for surrogate generation
    if (params.tf.scramble_phase)
        epoch = scramble_phase(epoch);
    end

    [wt frq] = twt(epoch, EEG.srate, get_scales(params, EEG.srate), params.wlt.bw);
    
    base_line_samples = time_to_samples(params.ana.baseline, EEG.srate);
    
    % shorten prefix by baseline number of samples to keep baseline in
    % spectra
    dstart = asummary.alimit{i}.prefix - base_line_samples;
    dend = asummary.alimit{i}.prefix+(asummary.alimit{i}.ep_end-asummary.alimit{i}.ep_start)-1;
    
    spectra(:,:,i) = wt(:,dstart:dend);
    
end
    

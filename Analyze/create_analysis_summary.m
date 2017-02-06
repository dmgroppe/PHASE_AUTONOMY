%USAGE: [asummary] = create_analysis_summary(params)
%   
%   Creates a summary off all the chanels to be analyzed, and their
%   associated epochs, truncated according to the analysis parameters
%
%   Input:
%       params:     Analysis parameters
%   Output:
%       asummary:   Summary of analyses to perform
%
%-------------------------------------------------------------------------

function [asummary] = create_analysis_summary(params)

if (~check_ana_params(params))
    return;
end

load([params.ana.dataDir params.ana.dataFile]);
tags = load_tags([params.ana.dataDir params.ana.tagFile]);

if (isempty(tags))
    display('Error loading tags.');
    return;
end

display_data_summary(EEG, tags);
display(' ');
display('Starting analysis:');

channel_n = length(params.ana.chlist);

asummary = cell(1,channel_n);

for i=1:channel_n
    channel = params.ana.chlist(i);
    display(sprintf('Collecting epochs from channel # %d', channel));
    epochs = collect_epochs(tags, params, channel);
    [shortest longest] = epoch_lengths(epochs);

    % Limit the epochs and get the range of analysis that also involves
    % padding the two sides of the epoch to avoid edge effects
    alimit = limit_epochs(epochs, params, EEG.srate, EEG.pnts);
    
    % Fix the length accordingly
    if (params.ana.fixed_length)
        alimit = truncate_to(alimit, time_to_samples(params.ana.length, EEG.srate));
    else
        alimit = truncate_to(alimit, time_to_samples(shortest, EEG.srate));
    end

    % Add a baseline to the epochs
    %alimit = add_baseline(alimit, time_to_samples(params.ana.baseline, EEG.srate));
    
    %Build the analysis summary
    asummary{i}.ch = channel;
    asummary{i}.epochs = epochs;
    asummary{i}.alimit = alimit;
end

%{
nchan = length(asummary);
for i=1:nchan
    display(sprintf('Summary for channel %d', asummary{i}.ch));
    asummary{i}.epochs{:}
    asummary{i}.alimits{:}
end
%}
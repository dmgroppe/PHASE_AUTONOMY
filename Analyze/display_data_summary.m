function [] = display_data_summary(EEG, tags)


display(' ');
display('From data file:');
display(sprintf('%s',EEG.comments));
display(sprintf('Number of channels:    %d',EEG.nbchan));
display(sprintf('Sampling rate:         %6.0f',EEG.srate));
display(sprintf('Total points:          %d',EEG.pnts));

display(' ');
display('From tag file:');
display(sprintf('Total number of tags   %d',length(tags)));


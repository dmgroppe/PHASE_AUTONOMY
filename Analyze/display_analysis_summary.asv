% USAGE: display_analysis_summary(asummary)
%
%  Last function to call when all the analysis summaries have been done
%       and the 

function [] = display_analysis_summary(asummary)


nchan = length(asummary);
if (isempty(asummary))
    display('No channels to analyze.')
    return;
end

display(sprintf('Number of channels: %d', nchan));

for i=1:nchan
    display(sprintf('**************Channel #%d ****************************', asummary{i}.ch));
    for j=1:length(asummary{i}.alimit)
        display(sprintf('    Epoch = %d', asummary{i}.epochs{j}.ep));
        display(sprintf('Prefix(%4.0f), ep_start(%4.0f), ep_end(%4.0f), suffix(%4.0f)',...
        asummary{i}.alimit{j}.prefix, asummary{i}.alimit{j}.ep_start, asummary{i}.alimit{j}.ep_end,...
        asummary{i}.alimit{j}.suffix));
    end
end
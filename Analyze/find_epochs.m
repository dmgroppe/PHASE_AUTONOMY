% USAGE: [epochs] = find_epochs(d, trigdir, offset, baseline_samples,
% threshold, min_trig_dur, show)
%
%--------------------------------------------------------------------------

function [epochs] = find_epochs(d, trigdir, offset, baseline_samples, threshold, min_trig_dur, show)

if (nargin < 7); show = ''; end;

if (strcmp(trigdir, 'neg'))
    d = -d;
end

d = d(offset:end);
d = d-mean(d(1:baseline_samples));

%threshold = 0.5*(max(d)-min(d));
npoints = length(d);

epoch_count = 0;
epochs = [];

pos = 1;
while(pos < npoints)
    
    [t_start epoch_start] = get_trigger(d, threshold, min_trig_dur, pos);
    if (epoch_start)
        [epoch_end, tend] = get_trigger(d, threshold, min_trig_dur, epoch_start + min_trig_dur);
        if (epoch_end)
            epoch_count = epoch_count+1;
            % The data was truncated by 'offset' points so need to add them
            % back
            epochs(:,:, epoch_count) = [epoch_start+offset epoch_end+offset];
            pos = epoch_end + 2*min_trig_dur;
        end
    end
    pos = pos+1;
end

if (strcmp(show, 'plot'))
    figure(1);
    hold on;
    plot(d);
    for i=1:epoch_count
        % Subtract off the the offset points
        plot(epochs(:,:,i)-offset, [threshold threshold]);
    end
    hold off;
end

function [t_start t_end] = get_trigger(d,threshold, min_trig_dur, start)

n=length(d);
t_start = 0;
t_end = 0;

for i=start:(n-2)
    if (d(i) <= threshold && d(i+2) >= threshold)
        t_start = i;
        for j=(i+min_trig_dur):n
            if (d(j) >= threshold && d(j+1) <= threshold)
                t_end = j;
                return;
            end
        end
    end
end
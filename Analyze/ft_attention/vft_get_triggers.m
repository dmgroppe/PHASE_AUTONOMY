function [onset offset edge] = vft_get_triggers(ts, corrupted, trigdur)

if nargin < 3; trigdur = 50; end;
if nargin < 2; corrupted = 0; end

if ~corrupted
    ats = abs(ts);

    ind = find(ats>2*mean(ats));
    dind = diff(ind);
    [~,plocs] = findpeaks(dind);
    trigdur = round(mean(diff(plocs)));

    tsmean = mean(ats);
    indb = ats>2*tsmean;

    count = 0;
    i=1;
    slevel = indb(1);

    while (i<length(indb))
        if indb(i) ~= slevel
            count = count + 1;
            edge(count) = i+1;
            slevel = ~slevel;
            i = i+trigdur/2;
        else
            i=i+1;
        end
    end

    onset = edge(2:4:length(edge));
    offset = edge(3:4:length(edge));   
else
    % This is for a patient that had the triggers filtered
    wd = abs(diff(diff(diff(ts))));
    indb = (wd > 2*mean(wd));
    ats = wd;
    
    count = 0;
    i=1;

    while (i<length(indb))
        if indb(i)
            count = count + 1;
            edge(count) = i;
            i = i+2*trigdur;
        else
            i=i+1;
        end
    end
    
    onset = edge(1:2:end)+trigdur;
    offset = [];
end

ntrig = length(edge);
if mod(ntrig,2)
    error('Error reading in triggers: too few triggers');
end

if 1
    plot(ats, '-k');
    hold on;
    plot(onset,ats(onset),'.g','MarkerSize', 15);
    if ~isempty(offset)
        plot(offset,ats(offset),'.r', 'MarkerSize', 15);
    end
end




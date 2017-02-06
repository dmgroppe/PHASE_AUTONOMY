function [event_locations] = template_match(w, minpeakdist, thresh, plength, inc,nstd)

w = w(:);

if nargin < 6; nstd = 1; end;
if nargin < 5; inc = 1; end;
if nargin < 4; plength = 50; end;

% plength = 50;  % Number of point to use for the parabola
% inc = 1;        % Decimate the data for the parabola fit
% nstd = 1;       % Cut off for final selection parabola steepness

t = 1:length(w);
h = figure(50);clf;
[~,loc] = findpeaks(w, 'MINPEAKDISTANCE', minpeakdist, 'THRESHOLD', thresh);
plot(w);
hold on;
plot(t(loc),w(loc), '.r','LineStyle', 'none');
hold off;

count = 0;
s = [];
for i=1:length(loc)    
    ind = ((loc(i)-plength):inc:loc(i)+plength);
    if min(ind) >=1 && max(ind) <= length(w)
        count = count + 1;
        s(:,count) = parab_fit(ind-loc(i),w(ind)');
    end
end

if size(s,2) > 3 
    ts = 1:size(s,2);
    figure(60);clf;
    plot(ts, s(3,:));

    minheight = std(s(3,:))*nstd;
    [~, p_locs] = findpeaks(-s(3,:), 'MINPEAKHEIGHT', minheight);

    hold on;
    plot(ts(p_locs), s(3,p_locs), '.r', 'LineStyle', 'none');
    hold off;

    figure(h);
    hold on;
    plot(loc(p_locs), w(loc(p_locs)), '.g', 'LineStyle', 'none');
    hold off;

    event_locations = loc(p_locs);
else
    event_locations = [];
end








function [s] = zap_plot_group_results(S)

% Plots the group results and collects the data into matrices from the cell
% arrays - stored in s

count = 0;
Zs = [];
Znorms = Zs;
ps = []; 
for i=1:numel(S)
    if ~isempty(S)
        count = count + 1;
        if count == 1;
            w = S{i}.w;
            fcenters = S{i}.fcenters;
        end
        Zs = [Zs S{i}.Z'];
        Znorms = [Znorms S{i}.Znorm'];
        ps = [ps S{i}.p_spike'];
    end
end

clf;
subplot(3,1,1);
Zmean = mean(Znorms,2);
Zconf = std(Znorms,1, 2)/sqrt(count);
boundedline(w, Zmean, Zconf, '-');
set(gca, 'XScale', 'linear', 'YScale', 'log');
axis([w(1) w(end) 0 1]);
xlabel('Frequency Hz');
ylabel('Znorm');
title(sprintf('Normalized Impedence from %d cells.', count));
set(gca, 'TickDir', 'out');

subplot(3,1,2);
pmean = mean(ps,2);
pconf = std(ps,1, 2)/sqrt(count);
boundedline(fcenters, pmean, pconf, '.-');
axis([w(1) w(end) 0 1.1]);
xlabel('Frequency Hz');
ylabel('Spike probability');
title(sprintf('Spike probability-freq plot %d cells.', count));
set(gca, 'TickDir', 'out');

subplot(3,1,3);
Zmean = mean(Zs,2);
Zconf = std(Zs,1, 2)/sqrt(count);
boundedline(w, Zmean, Zconf, '-');
set(gca, 'XScale', 'linear', 'YScale', 'log');

axis([w(1) w(end) 1 10e5]);
xlabel('Frequency Hz');
ylabel('Z');
title(sprintf('Impedence from %d cells.', count));
set(gca, 'TickDir', 'out');

s.Znorms = Znorms;
s.ps = ps;
s.Zs = Zs;




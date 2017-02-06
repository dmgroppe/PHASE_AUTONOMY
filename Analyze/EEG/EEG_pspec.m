function [] = EEG_pspec(EEG, srate, npoints)

if isfield(EEG, 'data')
    x = EEG.data;
else
    x = EEG;
end

[nchan, ~] = size(x);
x = x(:,1:npoints);

parfor i=1:nchan-2
    [ps(:,i),w(:,i)] = powerspec(x(i,:), srate,srate);
end

h = figure(2);
clf;

hold on;
for i=1:nchan-2
    plot(w(:,1),ps(:,i));
end
hold off;
set(gca,'XScale', 'log');
set(gca,'YScale', 'log');

set(h,'Name', EEG.comments);
xlabel('Frequency(Hz)');
ylabel('Power(\muV^2/Hz)');
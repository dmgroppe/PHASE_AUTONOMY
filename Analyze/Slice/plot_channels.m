function [] = plot_channels(S, nfig)

h = figure(nfig);

nchan = size(S.data,1);

for i=1:nchan
    ax(i) = subplot(nchan, 1, i);
    plot(S.data(i,:));
end

linkaxes(ax, 'xy');


a = linear_scale(1:5:S.srate/2, S.srate);

figure(nfig+1);
x=1:length(S.data);
labels.x = 'Sample points';
labels.y = 'Freq (Hz)';
labels.title = 'TF plot';
% 
% for i=1:nchan
%     [wt, freq] = twt(S.data(i,:), S.srate, a, 5);
%     scales = repmat(a,length(S.data),1)';
%     norm = abs(wt)./scales;
%     %norm = abs(wt);
%     ax(i) = subplot(nchan, 1, i);
%     labels.title = sprintf('TF plot CH %d', i);
%     labels.z.min = min(min(norm));
%     labels.z.max = max(max(norm));
%     generic_tf_plot(x, freq, norm, labels)
% end
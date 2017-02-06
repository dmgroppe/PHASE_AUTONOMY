function [] = Szprec_ccm_plot(sz_name, ch, varargin)

global DATA_PATH;

pt_name = strtok(sz_name, '_');

if~isempty(varargin)
    pelements = [{'Szprec', pt_name, 'Processed', 'CCM'} varargin sz_name];
    in_path = fullfile_from_list(DATA_PATH, pelements);
else
    in_path = fullfile(DATA_PATH, 'Szprec',  pt_name, 'Processed', 'CCM',sz_name);
end

% Check to see if the time_series analysis was done for this channel
ch = sort(ch);
fname = sprintf('%s_ccm_%d_%d.mat', sz_name,ch(1), ch(2));
ccm_file = fullfile(in_path, fname);
if ~exist(ccm_file, 'file')
    display('Time series analysis file does not exist.')
    return;
end

figure(1);clf;
load(ccm_file);
display_time_series(ccm_ts,chans,pt_name);
set(gcf, 'Name', sprintf('%s - CCM time series', sz_name));

figure(2);clf;
display_time_series(ccm_freqs,chans,pt_name);
set(gcf, 'Name', sprintf('%s - CCM freqs', sz_name));





function [] = display_time_series(R, ch, pt_name)
T_ccm = ((1:length(R.rf))-1)*((100-R.cfg.ccm.poverlap)/100)*R.cfg.ccm.win;
T_data = ((1:length(R.d))-1)/R.srate;
hpf = filter_highpass(2, R.srate, 100);
for i=1:2
    dfilt(:,i) = filtfilt(hpf.Numerator,1, R.d(:,i));
end

ch_labels = get_ch_info(pt_name, R.cfg);

ax(1) = subplot(3,1,1);
plot_data(dfilt(:,1), T_data, 'Time(s)', 'mV', sprintf('%s(%d)', ch_labels{ch(1)}, ch(1)));
ax(2) =  subplot(3,1,2);
plot_data(dfilt(:,2), T_data, 'Time(s)', 'mV', sprintf('%s(%d)', ch_labels{ch(2)}, ch(2)));

ax(3) = subplot(3,1,3);
plot_ccm(T_ccm, R.rf, R.rb, 11, pt_name, R.cfg, ch);
xlabel('Time (s)')
ylabel('rho');
linkaxes(ax, 'x');





function [] = plot_data(d, T, xl, yl, tit)

plot(T,d);
axes_text_style();
axis([T(1) T(end) min(d), max(d)]);
title(tit);
xlabel(xl);
ylabel(yl);

function [] = plot_ccm(T, rf, rb, smoothing, pt_name, cfg, ch)
rf_sm = smooth(get_ccm_values(rf), smoothing);
rb_sm = smooth(get_ccm_values(rb), smoothing);
[ch_labels] = get_ch_info(pt_name, cfg);
plot(T,rf_sm, T,rb_sm);
axis([T(1) T(end) -0.5 1]);
axes_text_style();
l{1} = sprintf('%s -> %s', ch_labels{ch(1)}, ch_labels{ch(2)});
l{2} = sprintf('%s -> %s', ch_labels{ch(2)}, ch_labels{ch(1)});
legend(l, 'FontSize', 7);
title('Cross-mapping results')


function [ch_labels] = get_ch_info(pt_name, cfg)
[ch_info] = names_from_bi_index(1, pt_name);
switch cfg.chtype
    case 'bipolar'
        ch_labels = ch_info.bi_labels;
    case'mono'
        ch_labels = ch_info.R.bi_labels;
end

function [r] = get_ccm_values(rho)

r = min(rho,[],1);

% npoints = size(rho,2);
% for i=1:npoints
%     [r ~] = corr(squeeze(rho(:,i)),(1:length(rho(:,i)))','type','Spearman');
%     if (r<0)
%         r(i) = min(rho(:,i));
%     else
%         r(i) = max(rho(:,i));
%     end
% end
    



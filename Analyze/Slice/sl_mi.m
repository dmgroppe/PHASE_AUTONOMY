function [] = sl_mi(ch,aslice, dop)


ap = sl_sync_params();
new_sr = 2000;
% 
% trange = [13.7*60 14.69*60];
% 
% [seg, T] = get_segment(data, ch, trange);
% [xdec, new_sr] = sl_filter_resample(seg, [0.001 new_sr/2], old_sr, new_sr);

switch aslice
    case 's1'
        Dir = 'D:\Projects\Data\Human Recordings\Human Cortex\Human cortex Nov 24\';
        % Good data from 822 to 881.4s
        fname = '11n24005';
        %tstart = 881.4-30;
        %tend = 881;
        % Activity that preceeds theta-gamma (looks inter-ictal)
        %tstart = 450;
        %tend = 480;
        % thet agamma a bit earlier than above
        tstart = 777;
        tend = 785;
    case 's2'
        Dir = 'D:\Projects\Data\Human Recordings\Human Cortex\Human cortex Nov 24\';
        % Good data from 997 to 1062s
        fname = '11n24018';
        tstart = 997;
        tend = 997+30;
    case 's3'
        %% Slice #3

        Dir = 'D:\Projects\Data\Human Recordings\Selected recordings for theta-gamma analysis\Set up 2\';
        fname = '11922007';
        tstart = 101;
        tend = 110;
end

%% Anlysis

% Load the data
S = abf_load(Dir,fname, new_sr, tstart, tend);
xdec = S.data(ch,:);
T = (0:(length(xdec)-1))/new_sr;


% Plot the data and band pass filtered data

% d = filter_data(xdec,3,new_sr/4,new_sr);
% theta = filter_data(xdec,4,8,new_sr);
% g1 = filter_data(xdec,30,50,new_sr);
% g2 = filter_data(xdec,60,150,new_sr);
% 
% h = figure(10);
% ax(1) = subplot(4,1,1);
% plot(T, d);
% title('Raw data');
% ax(2) = subplot(4,1,2);
% plot(T,theta);
% title('Theta');
% ax(3) = subplot(4,1,3);
% plot(T,g1);
% title('Low gamma');
% ax(4) = subplot(4,1,4);
% plot(T,g2);
% title('High gamma');
%  
% linkaxes(ax, 'xy');



xdec = S.data(ch,:);
T = (1:length(xdec))/new_sr;

%plot(T, seg);
[mi phase psig] = sl_mi_grid(xdec, new_sr, ap.mi.lfrange, ap.mi.hfrange,dop);
plot_mi(ap.mi.lfrange, ap.mi.hfrange, mi);

% figure(3);
% 
% [ps, w, pxx] = powerspec(xdec,2000, new_sr, 3);
% loglog(w,ps);
% axis([w(1) w(end) 10e-9 10e-3]);







function [xfilt] = filter_data(x, f1, f2, sr)
d = window_FIR(f1,f2,sr);
xfilt = filtfilt(d.Numerator, 1, x);


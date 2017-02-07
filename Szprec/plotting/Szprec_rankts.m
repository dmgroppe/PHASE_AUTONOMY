function [isokay, ax] = Szprec_rankts(F, srate, cfg, a_cfg, freq, sdir, nplots)
% function [isokay, ax] = Szprec_rankts(F, srate, cfg, a_cfg, freq, sdir, nplots)

if nargin < 6, nplots = 3; end;

% Make sure that the frequncy specified is found
% ind = find(cfg.freqs == freq); %DG COMMENTED OUT
% isokay = true;
% if isempty(ind) && ~a_cfg.rank_across_freqs
%     display('Frequency not found');
%     isokay = false;
%     return;
% end
isokay=true; %DG added

nchan = size(F,3);
cm = cbrewer('div', 'RdYlBu', 64);
cm = flipud(cm);

% Rank the channels.  fr are the values used to do the ranking.  It is
% assumed although not correctly that fr is 2dim matrix
[ranking, fr] = Szprec_rank1(F,cfg, a_cfg,sdir);

clf;
ax(1) = subplot (nplots,1,1);
T = (0:(length(F)-1))/srate;
colormap(cm);
imagesc(T,1:nchan, ranking');
axis([T(1) T(end) -1 nchan+2 0 1]);
set(gca, 'FontSize' , 7);
set(gca, 'TickDir', 'out');
view(0,90);
%colorbar;
xlabel('Time (s)');

if a_cfg.rank_across_freqs
    title('All frequncy (mean)channel rank', 'FontSize', 7);
else    
    title(sprintf('%dHz: Channel rank', freq), 'FontSize', 7);
end

ax_p1 = re_label_yaxis(sdir, cfg, T, nchan);

% Plot F for each channel
ax(2) = subplot(nplots,1,2);

%imagesc(T,1:nchan,zscore(log(fr))');
pf = p_norm(fr)';
imagesc(T,1:nchan,pf);
%axis([T(1) T(end) -1 nchan+2 0 1]);
if ~isempty(a_cfg.f_caxis)
    caxis(a_cfg.f_caxis);
end
set(ax(2), 'FontSize' , 7, 'TickDir', 'out');
view(0,90);
%colorbar;
xlabel('Time (s)');
title('Normalized preecursor values', 'FontSize', 7);

%linkaxes(ax, 'xy');
%re_label_yaxis(sdir, cfg);
ax_p2 = re_label_yaxis(sdir, cfg, T, nchan);

ax = [ax ax_p1 ax_p2];


% function [] = re_label_yaxis(sdir, cfg)
% 
% % see if there is channel info to be found
% R = names_from_bi_index(1, sdir);
% if ~isempty(R)
%     switch cfg.chtype
%         case 'bipolar'
%             labels = R.bi_labels;
%         case 'monopolar'
%             labels = R.m_labels;
%     end
%     set(gca, 'YTick', 1:numel(labels));
%     set(gca, 'YTickLabel', labels, 'FontSize', 5);
% end



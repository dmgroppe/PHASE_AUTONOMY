function [] = plot_f_multichan(F,srate, cfg, sdir)

clf
nplots = size(F,3);
[r c] = rc_plot(nplots);
T = (0:(length(F)-1))/srate;

gmax = max(max(max(F)));

% Try to get channel labels
[R] = names_from_bi_index(1, sdir);

% Set the channels labels or create them
if ~isempty(R)
    if strcmpi(cfg.chtype, 'bipolar')
        ch_labels = R.bi_labels;
    else
        ch_labels = R.m_labels;
    end
else
    for j=1:nplots
        ch_labels{j} = sprintf('%s ch#%d', cfg.chtype, j);
    end
end

count = 0;
for i=1:r
    for j=1:c
        count = count + 1;
        if count > nplots
            linkaxes(ax, 'x');
            break;
        end
        ax(count) = subplot(r,c,count);
        set(gca, 'FontSize', 5);
        f = squeeze(F(:,:,count))/gmax;
        if (min(min(f)) ~= max(max(f))) && isempty(find(isnan(f)==1, 1))% check to see if there is something to plot
            Z(:,:,count) = f./repmat(mean(f,2),1,length(f));
            f = Z(:,:,count);
        
            if size(f,1) == 1
                plot(T, f);
                axis([T(1) T(end) 0 10]);
                %title(sprintf('%s ch#%d', cfg.ch_type, count));

                xlabel('Time(s)');
                ylabel('Prec');
            else
                imagesc(T,cfg.freqs,f);
                axis([T(1) T(end) cfg.freqs(1) cfg.freqs(end) min(min(f)) max(max(f))]);
                view(0,90);
                %shading interp;
                %title(sprintf('%s ch#%d', cfg.chtype, count));
                xlabel('Time(s)');
                ylabel('Freq(Hz)');

                if ~isempty(cfg.plot_multichan_caxis)
                    caxis(cfg.plot_multichan_caxis);
                end
                drawnow;
            end
        end
        title(ch_labels{count});
    end
end
% 
% figure(2);clf;
% z = squeeze(mean(Z,3));
% if size(z,1) == 1
%     plot(T,z);
%     xlabel('Time(s)');
%     ylabel('Prec');
%     title(sprintf('%s - Grand average', ch_type));
% else
%     surf(T,freqs,z);
%     set(gca, 'YScale', 'log');
%     axis([T(1) T(end) freqs(1) freqs(end) 0 max(max(z))]);
%     view(0,90);
%     shading interp;
%     title(sprintf('%s - Grand average', ch_type));
%     xlabel('Time(s)');
%     ylabel('Freq(Hz)');
% end


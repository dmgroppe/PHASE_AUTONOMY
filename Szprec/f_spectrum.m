function [F] = f_spectrum(afunc, matrix_bi, srate, ch1, ch2, cfg, doplot)

if nargin < 7; doplot = 0; end;

matrix_bi =remove_nans(matrix_bi);

% Check for cfg parameters
if ~isfield(cfg, 'ncycles'); cfg.ncycles = 0; end;

wt1=twt(matrix_bi(:,ch1),srate,linear_scale(cfg.freqs, srate),5);
wt2=twt(matrix_bi(:,ch2),srate,linear_scale(cfg.freqs, srate),5);

F = feval(afunc, wt1, wt2, srate, cfg);

if doplot
    T = (0:(length(F)-1))/srate;
    if length(freqs) > 1

        ax(1) = subplot(4,1,1);
        plot(T,matrix_bi(:,ch1));
        axis([T(1) T(end) ylim]);
        xlabel('Time(s)');
        ylabel('\muV');
        title(sprintf('Bipolar ch#%d', ch1));

        ax(2) = subplot(4,1,2);
        plot(T,matrix_bi(:,ch2));
        axis([T(1) T(end) ylim]);
        xlabel('Time(s)');
        ylabel('\muV');
        title(sprintf('Bipolar ch#%d', ch2));

        ax(3) = subplot(4,1,3);
        surf(T,freqs,F);
        axis([T(1) T(end) freqs(1) cfg.freqs(end) min(min(F)) max(max(F))]);
        view(0,90);
        shading interp;
        title('Precursor');
        xlabel('Time(s)');
        ylabel('Freq(Hz)');

        ax(4) = subplot(4,1,4);
        Z = F./repmat(mean(F,2),1,length(F));
        surf(T,freqs,Z);
        axis([T(1) T(end) freqs(1) cfg.freqs(end) min(min(Z)) max(max(Z))]);
        view(0,90);
        shading interp;
        title('Z - Precursor');
        xlabel('Time(s)');
        ylabel('Freq (Hz)');

        linkaxes(ax, 'x');
    else
        % only a single frequency was selected
        ax(1) = subplot(3,1,1);
        plot(T,squeeze(matrix_bi(:,ch1)));
        axis([T(1) T(end) ylim]);
        xlabel('Time(s)');
        ylabel('\muV');
        title(sprintf('Bipolar ch#%d', ch1));

        ax(2) = subplot(3,1,2);
        plot(T,squeeze(matrix_bi(:,ch2)));
        axis([T(1) T(end) ylim]);
        xlabel('Time(s)');
        ylabel('\muV');
        title(sprintf('Bipolar ch#%d', ch2));
        
        ax(3)  = subplot(3,1,3);
        plot(T,squeeze(F));
        axis([T(1) T(end) ylim]);
        xlabel('Time(s)');
        ylabel('F');
        title(sprintf('Bipolar ch#%d', ch2));        
    end
end


function [x] = average(x,win)
c   = cumsum(x)./win;
x   = [c(win); c((win+1):end)-c(1:(end-win))];


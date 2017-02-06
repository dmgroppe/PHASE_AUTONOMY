function [] = tfa_tr(ts, srate, trange, frange, events, baseline, alpha, wnumber)

if nargin < 8; wnumber = 5; end;
if nargin < 7; alpha = 0.01; end;
if nargin < 6; baseline = 0; end;

s = linear_scale(frange, srate);
wt = twt(ts, srate, s, wnumber);
env = sqrt(abs(wt));

prange = fix(trange/1000*srate);
rlength = sum(abs(prange));

tfas = zeros(length(frange), sum(abs(prange)), length(events));
rls = tfas;

for i=1:length(events)
    tfas(:,:,i) = env(:,(events(i)+prange(1)):(events(i)+prange(2)-1));
    rls(:,:, i) = wt(:,(events(i)+prange(1)):(events(i)+prange(2)-1));
end

cv = abs(sum(exp(1i*angle(rls)),3)/length(events));

if baseline
    bpoints = fix(baseline/1000*srate);
    
    % Normalize each event to it's own baseline
    if bpoints
        for i=1:length(events)
            tfasn(:,:,i) = tfas(:,:,i)./repmat(mean(tfas(:,1:bpoints,i),2),1,length(tfas));
        end
    else
        tfasn = tfas;
    end
    
    %Compute STD at each time-freq bin
    tfa_std = squeeze(std(tfasn,1,3));
    tfa_norm = squeeze(mean(tfasn,3));
    tfa_bl = repmat(mean(tfa_norm(:,1:bpoints),2),1,length(tfa_norm));
    
    % P-values: using normal statistics since amplitude values are normally
    % distributed, then FDR correct
    ptfa = normcdf(tfa_norm,tfa_bl,tfa_std);
    p = reshape(ptfa,1,numel(ptfa));
    %sig_tfa = reshape(cfdr_vector(p, sort(p,'ascend'),0.05,1), size(ptfa));
    sig_tfa = reshape(fdr_vector(p, alpha), size(ptfa));
     
    % Compute the mean resultant length(R): Circ variance = 1-R
    cv = abs(squeeze(sum(rls,3))/length(events));
    cv_bl = repmat(mean(cv(:,1:bpoints),2),1,length(cv));
    
    % Normalize to the baseline
    cv_norm = cv./cv_bl;
    
    [nfreq npoints] = size(cv);
    % Use Rayleigh test to determine p-values at each time-freq bin
    for i=1:nfreq
        for j=1:npoints
            pcv(i,j) = circ_rtest(angle(squeeze(rls(i,j,:))));
        end
    end
    
    % FDR correct
    p = reshape(pcv,1,numel(pcv));
    %sig_cv = reshape(cfdr_vector(p, sort(p,'ascend'), 0.05,1), size(pcv));
    sig_cv = reshape(fdr_vector(p, alpha), size(pcv));
    
    
    % Check if no significant values
    if max(max(sig_tfa)) == 0
        tfa_plot = tfa_norm;
        ptext{1} = 'TFA - not signficant';
    else
        tfa_plot = tfa_norm.*sig_tfa;
        ptext{1} = 'TFA - significant';
    end
    
    if max(max(sig_cv)) == 0
        cv_plot = cv_norm;
        ptext{2} = 'CV - not signficant';
    else
        cv_plot = cv_norm.*sig_cv;
        ptext{2} = 'CV - significant';
    end
else
    % Just display the plots without normalization and no stats
    cv_plot = cv;
    tfa_plot = squeeze(mean(tfas,3));
    ptext{1} = 'TFA - no baseline correction';
    ptext{2} = 'CV - no baseline correction';
end

% Plot the amplitude
T = (0:(rlength-1))/srate*1000 + trange(1);
subplot(2,1,1);
plot_tfa(tfa_plot, T, frange, ptext{1});

% Plot the CV
subplot(2,1,2);
plot_tfa(cv_plot, T, frange, ptext{2});


function [] = plot_tfa(tfa, T, frange, t_text, crange)

if nargin < 5; crange = []; end;
set(gcf, 'Renderer', 'zbuffer');
surf(T,frange, tfa);
axis([T(1) T(end) frange(1) frange(end) min(min(tfa)), max(max(tfa))]);
set(gca, 'YScale', 'log', 'YMinorTick', 'on', 'TickDir', 'out');
yvals = get(gca,'YTickLabel');
set(gca,'YTickLabel',  10.^str2num(yvals));
view(0,90);
shading interp;
xlabel('Time (ms)');
ylabel('Frequency(Hz)');
title(t_text);
if ~isempty(crange)
    caxis(crange);
end
colorbar;




function [R] = sl_seizure(dap, dosave, plot_full_trace)

% for this function the dap, specifies the seizure times for a single
% file, and thus the seizure file name is the same for all entries in the
% dap.

if nargin < 2; dosave = 1; end;
if nargin < 3; plot_full_trace=0; end;

global DATA_DIR;

ap = sl_sync_params();
%user = user_get();
fname = char(dap(1).cond.fname);
decim = ap.sz_decim;
fhand = [];
    
% Don't notch since this will mess up the light pulse time series
ap.notch = 0;
ap.notch_ch_list = [1 0];
ap.srate = 0; % This forces the load to just the raw data


dap(1).Dir = fullfile(DATA_DIR, dap(1).Dir);
S = load_dap(dap(1), ap, fname);


% Get some constants
[nchan npoints] = size(S.data);

if ap.sz_plot_in_points
    T = 1:npoints;
else
    T = (0:(npoints-1))/S.srate;
end

nseizures = numel(dap);

lfp_chan = find(strcmp('LFP', dap(1).chlabels) == 1,1);
light_chan = find(strcmp('LIGHT', dap(1).chlabels) == 1,1);

if isempty(lfp_chan) || isempty(light_chan)
    error('Light and/or LFP channel have not been specified in the EXCEL spreadsheet.');
end


%% Collect all the light pulses
[P] = pulse_seq(S.data(light_chan,:));
%% Plot the full data trace, tags, seizures - this can take a long time if 
%  there are many pulses/trains in the data.

if plot_full_trace
    h = figure(1);clf;
    fig_name = sprintf('%s - Sz analysis - full plot', fname);
    set(h,'Name', fig_name);
    fhand = fig_handles(fhand,h,fig_name);
    
    plot_decimated(T,S.data(lfp_chan, :),1:length(T), decim, 'Times (s)', S.recChNames(lfp_chan));
    hdr.tags = S.tags;
    tags_plot(h, hdr, 'r');
    set(gca, 'position',[0.03 0.05 1 1], 'TickLength', [0.005 0.005]);

    for i=1:nseizures
         px = dap(i).cond.times;
         if px(1) == px(2)
             line(px,ylim,'Color', 'g');
         end

         patch([px(1) px(1) px(2) px(2)],[ylim fliplr(ylim)],'green', 'FaceAlpha', 0.3,...
            'EdgeColor', 'none');
    end
    if ~isempty(P)
        plot_light_pulses(P.range/S.srate);
    end
end

%% Plot the individual seizures and the light pulses
[r c] = rc_plot(nseizures);
h = figure(2); clf;
fig_name = sprintf('%s - Sz analysis - individual seizures', fname);
set(h,'Name', fig_name);
fhand = fig_handles(fhand,h,fig_name);

count = 0;
[ll] = line_length1(S.data(lfp_chan, 1:length(T)));
for i=1:r
    for j=1:c
        count = count + 1;
        if count > nseizures
            break;
        end
        subplot(r,c,count);
        points = fix(dap(count).cond.times*S.srate);       
        plot_decimated(T,S.data(lfp_chan, :), points(1):points(2),1, 'Times (s)', S.recChNames(lfp_chan));
        if ~isempty(P)
            szP(count) = get_ranges(P, points);
            if ~isempty(szP(count).minp) || ~isempty(szP(count).maxp)
                plot_light_pulses(P.range(szP(count).minp:szP(count).maxp,:)/S.srate);
                drawnow;
            end
            szStats{count} = do_stats(szP(count), lfp_chan, S,ap);
            if ~isempty(szStats{count})
                title(sprintf('LL pval = %6.4f', szStats{count}.ll_p));
            end
        else
            szStats{count} = [];
        end
            
    end
end


%% Plot the power spectra for the different seizures
h = figure(3); clf;
fig_name = sprintf('%s - Sz analysis - power spectra', fname);
set(h,'Name', fig_name);
fhand = fig_handles(fhand,h,fig_name);
count = 0;
for i=1:r
    for j=1:c
        count = count + 1;
        if count > nseizures
            break;
        end
        subplot(r,c,count);
        if ~isempty(szStats{count})
            [m_ps sem_ps, m_ps_int sem_ps_int] = ps_stats(szStats{count});
            ind = find( szStats{count}.w >= ap.sz_freq_plot(1) & szStats{count}.w <= ap.sz_freq_plot(2));
            loglog(szStats{count}.w(ind), m_ps(ind),szStats{count}.w(ind), m_ps_int(ind));
            label_axes('Freq (Hz)', 'Power');
            axis([min(szStats{count}.w(ind)) max(szStats{count}.w(ind)) ylim]);
            axes_text_style(gca);
            hold on;
            pval = (szStats{count}.ps_p <= ap.sz_alpha)*min(ylim)*10;
            loglog(szStats{count}.w(ind), pval(ind), 'r', 'LineWidth', 4);
            hold off;
        end
    end
end

% Package the results
R = struct_from_list('szP', szP, 'P', P, 'szStats', szStats);

%% Save the analyses, stats, and figures if specified
if dosave
    display('Saving figures and analyses...');
    save_dir = make_dir(fullfile(dap(1).Dir,'Figures'));
    for i=1:numel(fhand)
        save_figure(fhand(i).h, save_dir, fhand(i).name,1);
        saveas(fhand(i).h,fullfile(save_dir, [fhand(i).name '.fig']));
    end    
%     save_dir = make_dir(fullfile(dap(1).Dir,'Analyses'));
%     save(fullfile(save_dir, [fname '.mat']), 'R');
end
%% Functions
function [] = plot_decimated(T,x,pind, decim, xunits, yunits)
ind = min(pind):decim:max(pind);

plot(T(ind), x(ind), 'k');
axis([min(min(T(ind))) max(max(T(ind))) ylim]);
label_axes(xunits, yunits);
axes_text_style(gca);

% Get the light pulses from the pulse channel and plot them
function [] = plot_light_pulses(px)
npulses = size(px,1);

for i=1:npulses
    line([px(i,1) px(i,1)],ylim,'Color', 'b');
    patch([px(i,1) px(i,1) px(i,2) px(i,2)],[ylim fliplr(ylim)],'blue', 'FaceAlpha', 0.1,...
       'EdgeColor', 'none');
end

function [R] = get_ranges(P, points)

% Return the time ranges for the light pulses and inter pulse times wiht a
% specified time range(points);

lp = [];
lp_int = [];

minp = find(P.range(:,1) > points(1),1);
maxp = find(P.range(:,2) < points(2));

% Don't use light pulses that extend beyond the specified time range 
if ~isempty(maxp) && numel(maxp) ~= 1
    maxp = maxp(end);
end
if ~isempty(minp) || ~isempty(maxp)
    p = P.range(minp:maxp,:);
    npulses = size(p,1);
    if npulses >= 1
        pint = P.isi(minp:maxp,:); 
        if npulses == 1
            pintend = pint(1)+p(2)-p(1);
            if pintend <= points(2)
               lp(:,1) = [p(1,1) p(1,2)];
               lp_int(:,1) = [p(1,2) pintend];
            end    
        else
            for k=1:npulses
                lp(:,k) = [p(k,1) p(k,2)];
                if (pint(k,2) > points(2))
                    pint(k,2) = pint(k,1) + lp_int(2,k-1) - lp_int(1,k-1);
                end
                lp_int(:,k) = [pint(k,1) pint(k,2)];
            end
        end
    end
else
    lp = [];
    lp_int = [];
end

R = struct_from_list('lp', lp, 'lp_int', lp_int, 'minp', minp, 'maxp', maxp);

function [R] = do_stats(szP, chan, S,ap)

npulses = size(szP.lp,2);
[ll] = line_length1(S.data(chan, 1:length(S.data)));

if ~isempty(szP.minp) || ~isempty(szP.maxp)
    if npulses >= 1
        % Line length calculation
        for k=1:npulses
            llsum(k) = ll(szP.lp(2,k)) - ll(szP.lp(1,k));
            llsum_int(k) = ll(szP.lp_int(2,k)) - ll(szP.lp_int(1,k));
        end
        [R.ll_p,~] = ranksum(llsum, llsum_int);
        
        % Do the power spectrum stats
        ps = [];
        ps_int = [];
        for k=1:npulses
            seg = S.data(chan, szP.lp(1,k):szP.lp(2,k));
            if (length(seg) > S.srate*ap.sz_pspec_win)
            
                hwin = hann(length(seg));
                [ps(:,k),w,ps_pxx(:,:,k)] = powerspec(hwin.*seg(:), S.srate*ap.sz_pspec_win, S.srate);

                seg = S.data(chan,szP.lp_int(1,k):szP.lp_int(2,k));
                hwin = hann(length(seg));
                [ps_int(:,k),~,ps_int_pxx(:,:,k)] = powerspec(hwin.*seg(:), S.srate*ap.sz_pspec_win, S.srate);
            end
        end
        
        if ~isempty(ps) || ~isempty(ps_int)
            ps_pxx = shiftdim(ps_pxx,1);
            [m,n,p] = size(ps_pxx);
            ps_pxx = reshape(ps_pxx,m,n*p);

            ps_int_pxx = shiftdim(ps_int_pxx,1);
            [m,n,p] = size(ps_int_pxx);
            ps_int_pxx = reshape(ps_int_pxx,m,n*p);

            for i=1:length(w)
                R.ps_p(i) = ranksum(ps_int_pxx(i,:), ps_pxx(i,:), 'method', 'approximate');
            end
            R.ps_pxx = ps_pxx;
            R.ps_int_pxx = ps_int_pxx;
            R.w = w;
        else
            R = [];
        end
    else
        R = [];
    end
else
    R = [];
end

function [m_ps sem_ps, m_ps_int sem_ps_int] = ps_stats(szStats)
m_ps = mean(szStats.ps_pxx,2);
nspec = size(szStats.ps_pxx,2);
sem_ps = std(szStats.ps_pxx,[],2)/sqrt(nspec);

m_ps_int = mean(szStats.ps_int_pxx,2);
nspec = size(szStats.ps_int_pxx,2);
sem_ps_int = std(szStats.ps_int_pxx,[],2)/sqrt(nspec);


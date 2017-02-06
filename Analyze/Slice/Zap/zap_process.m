function [R] = zap_process(dap, Dir, fn, doplot, tfactor, i_amp,...
    threshold, frange, interp_w)

if nargin < 4; doplot = 0; end;

if nargin < 5; tfactor = 1; end;
if nargin < 6; i_amp = 1; end;
if nargin < 7; threshold = -30; end;
if nargin < 8; frange = [0 20]; end;
if nargin < 9; interp_w = []; end;

ap = sl_sync_params();

Z = [];
sp_freqs = [];
isSpiking = false;

path = fullfile(Dir, [fn '.abf']);
if ~exist(path, 'file')
    display('File does not exist');
    return;
end

set(gcf, 'Name', fn);

[d,si,h]=abfload(path);

if size(d,3) > 1
    % This means there were multiple episodes so not a ZAP function
    display(sprintf('%s - is like not a ZAP  protocol', upper(fn)));
    return;
end

% Handle what happens when different numbers of channels are recorded from
if size(d,2) == 1
    display('Two channels were not acquired, using synthetic current channel');
    tempd = d;
elseif size(d,2) == 2
    % Assume CH1 is V, and CH2 is I
    tempd = d;
else
    if ~isempty(dap.chlabels)
        vind = find_text(dap.chlabels, 'V');
        iind = find_text(dap.chlabels, 'I');
        if ~isempty(vind) && ~isempty(iind)
            tempd =  d(:,[vind iind]);
        else
            tempd = d(:,[1,2]);
        end
    else
        % assumme that the first two channels are V and I respectively
        % although this should have been set up in the excel spreadsheet
        tempd = d(:,[1,2]);
    end
end
d = tempd;

sr = 1/(si*1e-6);
T = (0:length(d)-1)/sr;

% dataSeg = find(T>ap.zap.tstart & T < ap.zap.tend);
% T = T(dataSeg);
% d = d(dataSeg, :);

%find the spikes
sp = find(d(:,1) < threshold);
sp_start = find(diff(sp) > 1);
sp_ind = sp(sp_start);

% Create synthetic zap function
[z, ~, f] = zap(1, frange*tfactor, frange(2)/tfactor, sr);
f = [zeros(1,fix(ap.zap.tstart*sr)) f];
f = [f zeros(1,length(T)-length(f))];
syn_zap = zeros(1,length(d));
syn_zap(1:(1+length(z)-1)) = z;

% Get the spike times
sp_freqs = [];

% Find the transitions to positive values
steps = find(abs(diff(syn_zap>0)) > 0);
[~, locs] = findpeaks(syn_zap);

for i=1:2:length(steps)
    if ~isempty(intersect(steps(i):steps(i+1), sp_ind))
        sp_freqs = [sp_freqs f(locs(fix((i+1)/2)))];
    end   
end

zap_peak_edges = f(steps);

if doplot
    naxis = 1;
    clf;
    ax(naxis) = subplot(3,2,1);
    plot(T,d(:,1));
    ylabel(h.recChUnits{1});
    xlabel('Time(s)');
    axis([T(1) T(end) ylim]);

    % Plot the spikes
    if length(sp_ind)
        hold on;
        plot(T(sp_ind), d(sp_ind,1), '.g', 'MarkerSize',5);
        hold off;
    end

    % Plot the current waveform
    if size(d,2) == 2
        naxis = naxis + 1;
        ax(naxis) = subplot(3,2,3);
        plot(T,d(:,2));
        ylabel(h.recChUnits{2});
        xlabel('Time(s)');
        axis([T(1) T(end) ylim]);
    end

%     naxis = naxis + 1;
%     ax(naxis) = subplot(3,2,5);
%     plot(T,syn_zap*i_amp);
%     ylabel('Units');
%     xlabel('Time(s)');
%     axis([T(1) T(end) ylim]);
    
    linkaxes(ax, 'x');
end


if length(sp_ind)
    display('Spiking detected impedence estimate may not be accurate.');
    Z = [];
    isSpiking = true;
    %return;
end

dInd = find(T <= ap.zap.tstart & T < ap.zap.tend);
dTrunc = d(dInd, :);

%bp = window_FIR(frange(1)+.01,frange(2), sr, 1000);

voltage = dTrunc(:,1);
current = dTrunc(:,2);

[V, w, ~] = powerspec(voltage, length(voltage), sr);
if size(d,2) == 2
    I = powerspec(current, length(current), sr);
else
    I = powerspec(syn_zap*i_amp, length(syn_zap), sr);
end

Z = V./I*(1e-3/1e-12)* (max(current)/50)/50/1e6;
subplot(3,2,2);
f_ind = find(w >=0 & w < frange(2));
new_w = w(f_ind);
loglog(w(f_ind),Z(f_ind));
xlabel('Frequency (Hz)');
ylabel('Z (MOhms)');
axis([new_w(1) new_w(end) ylim]);

subplot(3,2,4);
loglog(w(f_ind),Z(f_ind)/max(Z(f_ind)));
xlabel('Frequency (Hz)');
ylabel('normalized Z');
axis([new_w(1) new_w(end) ylim]);

if ~isempty(interp_w)
    wmax = min([max(interp_w) max(w)]);
    wmin = max([min(interp_w) min(w)]);
    inc = mean(diff(interp_w));
    new_interp_w = wmin:inc:wmax;
    Z_interp = interp1(w,Z,new_interp_w);
    Z = Z_interp;
    w_interp = new_interp_w;
    
    subplot(3,2,6);
    loglog(w_interp,Z/max(Z));
    xlabel('Frequency (Hz)');
    ylabel('normalized Z');
    axis([0 w_interp(end) ylim]);
    title('Interpolated Z');
else
    Z_interp = [];
    w_interp = [];
end

R = struct_from_list('sp_freqs', sp_freqs, 'Z', Z, 'w', w, 'zap_peak_edges',...
        zap_peak_edges, 'isSpiking', isSpiking, 'Z_interp', Z_interp, 'w_interp', w_interp);













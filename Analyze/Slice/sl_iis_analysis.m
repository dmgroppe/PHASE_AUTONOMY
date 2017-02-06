function [] = sl_iis_analysis(dap, trange, S)

global DATA_DIR;

% Get default analysis params
ap = sl_sync_params();

% Load the data

if nargin < 3
    ap.notch = 0;
    ap.notch_ch_list = [1 0];
    ap.srate = 0; % This forces the load to just the raw data
    fname = char(dap(1).cond.fname);
    dap(1).Dir = fullfile(DATA_DIR, dap(1).Dir);
    S = load_dap(dap(1), ap, fname);
end

[nchan npoints] = size(S.data);
% The time range of analysis
T = (0:(npoints-1))/S.srate;
t = find(T>= trange(1) & T<=trange(2)); % subregion time range
prange = trange*S.srate;

% Find the appropriate channels
lfp_chan = find(strcmp('LFP', dap(1).chlabels) == 1,1);
light_chan = find(strcmp('LIGHT', dap(1).chlabels) == 1,1);
if isempty(lfp_chan) || isempty(light_chan)
    error('Light and/or LFP channel have not been specified in the EXCEL spreadsheet.');
end

% Collect all the light pulses
[P] = pulse_seq(S.data(light_chan,:));

if isempty(P)
    error('No light pusles detected.');
end

count = 0;
e_count = 0;
for i =1:(length(P.range)-1)
    if (P.range(i,1) >= prange(1) &&  P.range(i,2) <= prange(2))
        % Make sure the pulse is in the specified time range
        count = count + 1;
        tpts = [(P.range(i,1)-ap.ev_prefix*S.srate) (P.range(i,1)+ap.ev_suffix*S.srate)-1];
        template(:,count) = smooth(S.data(lfp_chan,tpts(1):tpts(2)), ap.ev_smooth);
        
        % Convolve the template with the data between the light pulses
        %drange = [P.range(i,1)-length(template)  P.range(i+1,1)+length(template)];
        drange = [P.range(i,1)-length(template)  P.range(i,1)+2*length(template)];
        
        if drange(1)>= 1 && drange(2) <= npoints
            temp = template(:,count);
            d = S.data(lfp_chan, drange(1):drange(2));
            w = conv(d(:)-mean(d), temp(:)-mean(temp));
            %w = w((length(temp)+1):end-length(temp));
            figure(80);plot(temp)
            figure(81);plot(d);
            figure(82);plot(w)
            [ev_loc] = template_match(w, ap.ev_minpeakdist*S.srate, ap.ev_thresh, ...
                ap.ev_plength, ap.ev_inc, ap.ev_nstd);

           if ~isempty(ev_loc)
                figure(80);
                plot(d);
                hold on;
                plot(ev_loc+length(temp), d(ev_loc+length(temp)), '.r', 'LineStyle', 'none');
                hold off;

                e_count = e_count + 1;
                R.events{e_count} = ev_loc + P.range(i,1)-1;
                R.pind(e_count) = i;
                R.tind(e_count) = count;
           end
        end
    end
end
    
    




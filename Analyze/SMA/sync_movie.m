% USAGE: analyze_SMA(EEG, cond, frange, atype, length, alpha)
%
%   Computes the syn matrix according to various type of measures of
%   synchrony
%   Return: sync matrix, and significance if computed

function [M] = sync_movie(EEG, cond, frange, slength, refch, chs, w_length, overlap)
tic

%doabs = 1;
atype = 'wpli';
axis_range = [-1 1];
threshold = .2770;

[eDir] = get_export_path_SMA();
[tstart tend] = get_trange(cond, slength);

aparams = get_default_params();
aparams.ana.nsurr = 200;
aparams.sync.lowcut = frange(1);
aparams.sync.highcut = frange(2);

%fprintf('\nStarting: %s\n',datestr(now));
%fprintf('%s %4.0f-%4.0fHz %s alpha %6.4f\n', upper(cond),...
%            aparams.sync.lowcut, aparams.sync.highcut, upper(atype), alpha);
        
subr = get_subregion(EEG, tstart, tend);
subr = subr(1:EEG.nbchan-1,:);

nframes = fix((length(subr)-w_length)/(w_length*(1-overlap/100)));
syncs = zeros(length(chs), nframes);
ref_ch_index = find(chs == refch);
h = hilberts(subr(chs,:), EEG.srate, aparams);

for i=1:nframes
    sstart = fix((i-1)*w_length*(1-overlap/100))+1;
    send = sstart + w_length-1;
    syncs(:,i) = sync_with_ref(h(:,sstart:send), atype, ref_ch_index);
end

M = make_movie(syncs, chs, axis_range, threshold, 1);

function [h] = hilberts(data, srate, aparams)

d = window_FIR(aparams.sync.lowcut, aparams.sync.highcut, srate);
Num = d.Numerator;

[nchan, npoints] = size(data);
h = zeros(nchan, npoints);

 parfor i=1:nchan
     h(i,:) = hilbert(filtfilt(Num, 1, data(i,:)));
 end
 
function [sync] = sync_with_ref(h, atype, ref_chan_index)

fh = sync_fh(atype);

nchan = size(h,1);
sync = zeros(1,nchan);

for i=1:nchan
    if i == ref_chan_index
        sync(i) = 1;
    else
        sync(i) = fh(h(ref_chan_index,:), h(i,:));
    end
end

function [M] = make_movie(syncs, chs, axis_range, threshold, nfig)

h = figure(nfig);
[schematic, elist] = load_electrode_schematic();
show_schematic(schematic);

nframes = size(syncs,2);

for i=1:nframes
    p_syncs = syncs(:,i);
    indicies = find(abs(p_syncs) < threshold);
    p_syncs(indicies) = [];
    p_chs = chs;
    p_chs(indicies) = [];
    plot_on_schematic(p_syncs, p_chs, elist, axis_range, []);
    M(i) = getframe;
end
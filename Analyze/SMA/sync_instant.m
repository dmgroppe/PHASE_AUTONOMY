function [pc r2] = sync_instant(EEG, cond, ch_pairs, frange, ptname, slength, twidth)

% Get the data from the EEG
[tstart tend] = get_trange(cond, slength, ptname);
subr = get_subregion(EEG, tstart, tend);

%find the unique channels to grab
uchannels = unique_from_pairs(ch_pairs);
subr = subr(uchannels, :);

aparams.sync.lowcut = frange(1);
aparams.sync.highcut = frange(2);

% Compute the hilbert transforms
h = hilberts(subr, EEG.srate, aparams);

% Number of points to compute near instantaneous synchronization
nframes = fix((length(subr)-twidth)/twidth);

r2 = zeros(1,nframes);
pc = zeros(1,nframes);

figure(1);

amp_pairs = zeros(2,length(ch_pairs));
dphis = zeros(1,length(ch_pairs));
for i=1:nframes
    tstart = (i-1)*twidth + 1;
    tend = tstart + twidth-1;
    
    slice = h(:,tstart:tend);
    amps = abs(slice);
    angles = angle(slice);
    
    % cycle through the pairs and compute amplitude and phase difference
    % for all the pairs submitted
    
    for j=1:length(ch_pairs)
        i1 = find(uchannels == ch_pairs(1,j));
        i2 = find(uchannels == ch_pairs(2,j));
        amp_pairs(:,j) = [amps(i1), amps(i2)];
        dphis(j) = angles(i1) - angles(i2);
        
    end
    %scatter(amp_pairs(1,:), amp_pairs(2,:));
    %pc(i) = sqrt(mean(sin(dphis))^2 + mean(cos(dphis))^2);
    %r2(i) = corr(amp_pairs(1,:)',amp_pairs(2,:)', 'type', 'Spearman');
    pc(i) = mean(sign(dphis));
    r2(i) = mean(amps);
end

ax(1) = subplot(2,1,1);
plot(pc);
ax(1) = subplot(2,1,2);
plot(r2);

linkaxes(ax);









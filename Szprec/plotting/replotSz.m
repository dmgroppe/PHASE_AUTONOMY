function [] = replotSz(sz_name, channels, fband, sp_freqs, plot_freqs)

% Replots individual channels, their spectrogram, PA values, and iEEG

global DATA_PATH;

if nargin <3; fband = false; end;
    
if nargin < 4;
    sp_freqs = [1:10 12:2:60 70:5:120 125];
end

if nargin < 5;
    plot_freqs = [6 10 20 30 60 100];
end



nchan = length(channels);

% Load the summary figure

pt_name = strtok(sz_name, '_');

cm = cbrewer('div', 'RdYlBu', 64);
cm = flipud(cm);
for i=1:nchan
    h = figure(i+1);clf;
    colormap(cm);
    z(i) = channelZoom(pt_name, sz_name, channels(i), 'bipolar', sp_freqs, plot_freqs, fband);
end

% If there are two channels then do phase coherence analysis between the
% two
pc_cfg = cfg_default();
pc_cfg.ncycles = 10;
pc_cfg.freqs = sp_freqs;
pc_cfg.win = 1;
pc_cfg.use_fband = false;

if nchan == 2
    phase_coh = Szprec_phase_coherence(z(1).wt, z(2).wt, z(1).Sf, pc_cfg);

    h = figure(nchan+2);clf;
    %ax(1) = subplot(3,1,1);
    set(h,'Name', sprintf('Phase coherence %s to %s', z(1).bi_labels{channels(1)},z(1).bi_labels{channels(2)}));
    surf(z(1).T, sp_freqs, phase_coh);
    [~, fi] = intersect(sp_freqs, plot_freqs);
    pfreqs = sp_freqs(fi);
    axis([z(1).T(1) z(1).T(end) sp_freqs(1), sp_freqs(end) 0 1]);
    caxis([0 1]);
    %set(gca, 'YScale', 'log', 'YTick', pfreqs);
    set(gca, 'YScale', 'log', 'YTick', pfreqs, 'FontSize', 7);
    set(gca, 'TickDir', 'out');
    view(0,90);
    shading interp;
end
% 
% ax(2) = subplot(3,1,2);
% [pac ~] = trpac(z(1).d, z(1).Sf, [8 12], [30 60], 10, 0);
% plot(z(1).T, pac);
% axis([z(1).T(1) z(1).T(end) 0 1]);
% title(sprintf('PAC - %s',z(1).bi_labels{channels(1)}));
% 
% linkaxes(ax, 'x');
% 
% ax(3) = subplot(3,1,3);
% [pac ~] = trpac(z(2).d, z(2).Sf, [1 4], [30 60], 10, 0);
% plot(z(1).T, pac);
% axis([z(1).T(1) z(1).T(end) 0 1]);
% title(sprintf('PAC - %s',z(2).bi_labels{channels(2)}));
% linkaxes(ax, 'x');




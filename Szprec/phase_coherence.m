function [F] = phase_coherence(wt1, wt2, srate, cfg)

% Phase coherence

if isfield(cfg, 'use_fband'); cfg.use_fband = false; end;
if ~isfield(cfg, 'ncycles');cfg.ncycles = 0; end;
if ~isfield(cfg, 'win'); cfg.win = 1; end;

% Phase difference
R=wt1.*conj(wt2)./(abs(wt1).*abs(wt2));

npoints = length(wt1);


% Deteremine the averaging windows as a function of frequency
if cfg.ncycles
    win = fix(cfg.ncycles./cfg.freqs*srate);
else
    win = fix(srate./cfg.win);
end

%Compute the phase coherence
if ~cfg.use_fband
    F = zeros(length(cfg.freqs), npoints);

    for i=1:length(cfg.freqs)
        t=R(i,:)';
        t = padarray(t,[fix(win(i)/2)+1 0],'replicate');
        f = abs(average(t, win(i)));
        F(i,:) = f(1:npoints);
    end
else
    % Currently nto using this analysis
    if cfg.ncycles
        win = fix(cfg.ncycles/mean(cfg.fband)*srate);
    else
        win = fix(srate/cfg.win);
    end
    t = padarray(R,[fix(win/2)+1 0],'replicate');
    f = average((t), win);
    F = f(1:npoints);
end
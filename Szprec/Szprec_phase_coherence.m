function [F] = Szprec_phase_coherence(wt1, wt2, srate, cfg)


% Phase difference
R = wt1.*conj(wt2)./(abs(wt1).*abs(wt2));

npoints = length(wt1);


% Deteremine the averaging windows as a function of frequency

%Compute the phase coherence
if ~cfg.use_fband
    F = zeros(length(cfg.freqs), npoints);
    
    if cfg.ncycles
        win = fix(cfg.ncycles./cfg.freqs*srate);
    else
        win = fix(srate./cfg.win);
    end

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
    f = abs(average((t), win));
    F = f(1:npoints);
end
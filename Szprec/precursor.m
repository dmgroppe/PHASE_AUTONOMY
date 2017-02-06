function [F] = precursor(wt1, wt2, srate, cfg)

if ~isfield(cfg, 'use_fband'); cfg.use_fband = false; end;
if ~isfield(cfg, 'ncycles');cfg.ncycles = 10; end; % 10 cycles default
if ~isfield(cfg, 'win'); cfg.win = 1; end; % 1s default
if ~isfield(cfg, 'diff_adaptive'); cfg.diff_adaptive = true; end;
if ~isfield(cfg, 'diff_adaptive_rads'); cfg.diff_adaptive_rads = pi; end;

R = wt1.*conj(wt2)./(abs(wt1).*abs(wt2));
Ab = unwrap(angle(R),[],2);

npoints = length(wt1);

if cfg.ncycles
    win = fix(cfg.ncycles./cfg.freqs*srate);
else
    win = fix(srate./cfg.win);
end

if ~cfg.use_fband
    F = zeros(length(cfg.freqs), npoints);

    for i=1:length(cfg.freqs)
        t=Ab(i,:)';

        t = padarray(t,[fix(win(i)/2)+1 0],'replicate');
        deriv = derivative(t, cfg, srate, cfg.freqs(i));
        f = average(abs(deriv), win(i));
        F(i,:) = f(1:npoints);

    end
else
    % Derivative not implemented for this computation
    if cfg.ncycles
        win = fix(cfg.ncycles/mean(cfg.fband)*srate);
    else
        win = fix(srate/cfg.win);
    end
    t = padarray(Ab,[fix(win/2)+1 0],'replicate');
    deriv = derivative(t, cfg, srate, mean(cfg.fband));
    f = average(abs(deriv), win);
    F = f(1:npoints);
end

function [deriv] = derivative(x, cfg, srate, f)
if cfg.diff_adaptive
    p = fix((1/(2*pi*f))*cfg.diff_adaptive_rads*srate);
    if ~p
        deriv = diff(x);
    else
        deriv = diff_n(x,p);
    end
    
else
    deriv = diff(x);
end

deriv = deriv(:);
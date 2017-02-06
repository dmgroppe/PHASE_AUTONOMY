function [F] = precursor_var(wt1, wt2, srate, cfg)

% Precursor as coded by Frank Mei - which is rate of change of the phase
% difference

if ~isfield(cfg, 'use_fband'); cfg.use_fband = false; end;
if ~isfield(cfg, 'ncycles');cfg.ncycles = 0; end;
if ~isfield(cfg, 'win'); cfg.win = 1; end;

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
    win = 100;

    for i=1:length(cfg.freqs)
        f = var_windowed(Ab(i,:)', win)*win; % Normalize to window size
        F(i,:) = f(1:npoints);
    end
else
    % Derivative not implemented for this computation
    if cfg.ncycles
        win = fix(cfg.ncycles/mean(cfg.fband)*srate);
    else
        win = fix(srate/cfg.win);
    end
    f = var_windowed(Ab, win);
    F = f(1:npoints);
end
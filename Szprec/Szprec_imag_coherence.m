function [F] = Szprec_imag_coherence(wt1, wt2, srate, cfg)


% Check for default fields
if ~isfield(cfg, 'freqs')
    display('No freqeuncies specified');
    return;
end
if ~isfield(cfg, 'ncycles'); cfg.ncycles = 10; end

% Imaginary part of coherence
npoints = length(wt1);

%Phase difference
R = wt1.*conj(wt2)./(abs(wt1).*abs(wt2));
a1 = abs(wt1);
a2 = abs(wt2);
ic = a1.*a2.*imag(R)./repmat(sqrt(mean(a1.^2,2).*mean(a2.^2,2)),1,npoints);

% Deteremine the averaging windows as a function of frequency
win = fix(cfg.ncycles./cfg.freqs*srate);

F = zeros(length(cfg.freqs), npoints);

for i=1:length(cfg.freqs)
    t = ic(i,:)';
    t = padarray(t,[fix(win(i)/2)+1 0],'replicate');
    f = abs(average(t, win(i)));
    F(i,:) = f(1:npoints);
end
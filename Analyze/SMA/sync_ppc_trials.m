function [rho, p, mean_phase] = sync_ppc_trials(EEG, ch, cond, ptname, dosave, doplot)


if nargin < 5; doplot = 0; end;
if nargin < 5; dosave = 0; end;

% Save the analysis info in AP
ap = sync_params();
[bins,x] = make_phase_bins(ap.ppc.nbins);
nbins = length(bins);
nfreqs = length(ap.freqs);
ap.condlist{1} = cond;
ap.ptname = ptname;
ap.chlist = ch;

if ap.surr
    fname = sprintf('PPC TRIALS SURR %s %s %d&%d', upper(ptname), upper(cond), ch(1), ch(2));
else
    fname = sprintf('PPC TRIALS %s %s %d&%d', upper(ptname), upper(cond), ch(1), ch(2));
end

% Get the data
[tstart tend] = get_trange(cond, ap.length, ptname);
subr = get_subregion(EEG, tstart, tend);
subr = subr(ch,:);

% For surrogate generation
if ap.surr
    if ap.scramble_phase
        subr(1,:) = scramble_phase(subr(1,:));
    else
        subr(1,:) = rand_rotate(subr(1,:));
    end
end

% Wavelet transforms
wt1 = twt(subr(1,:), EEG.srate, linear_scale(ap.freqs, EEG.srate), ap.wnumber);
wt2 = twt(subr(2,:), EEG.srate, linear_scale(ap.freqs, EEG.srate), ap.wnumber);

segs = 1:ap.ppc.window:length(subr);
nsegs = length(segs);

tic
rho = zeros(nfreqs, nbins,nsegs-1);
p = rho;
mean_phase = zeros(nfreqs, nsegs-1);

for i=1:length(segs)-1
    sstart = segs(i);
    send = segs(i+1);
    for j=1:length(ap.freqs)
        [~, ~, rho(j,:,i), p(j,:,i), ~, mean_phase(j,i)] = sync_ppc(wt1(j,sstart:send),...
            wt2(j,sstart:send), ap.ppc.nbins);
    end
end
toc

if dosave
% Package the results;
    R.rho = rho;
    R.p = p;
    R.ap = ap;
    R.mean_angle = mean_phase;
    R.bins = bins;
    R.x = x;
    save([get_export_path_SMA() fname '.mat'], 'R');
end

if doplot
    colormap(jet);
    h = figure(1);
    clf('reset');
    set(h, 'Name', fname);

    meanrho = mean(rho,3);
    plot_ppc(x, meanrho, ap)

    if dosave
        save_figure(h, get_export_path_SMA(), fname);
    end
end

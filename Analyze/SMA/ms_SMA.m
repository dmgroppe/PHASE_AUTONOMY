% USAGE: function [wts frqs mp ms] = ms_SMA(EEG, cond, slength, ch, window, bs)

function [wts frqs mp ms] = ms_SMA(EEG, cond, slength, ch, window, bs)

if nargin < 6; bs = 0; end

[tstart tend] = get_trange(cond, slength);

aparams = get_default_params();
aparams.tf.fstart = 1;
aparams.tf.finc = 1;
aparams.tf.fend = 200;
aparams.display.cfm.fstart = 1;
aparams.display.cfm.fend = 30;
aparams.ana.nsurr = 500;
alpha = 0.05;

[eDir] = get_export_path_SMA();

ts = EEG.data(ch, tstart*EEG.srate/1000:tend*EEG.srate/1000);
nsegments = floor(length(ts)/window);

scales = get_scales(aparams, EEG.srate);
nscales = length(scales);

wts = zeros(nscales, window, nsegments);
[wt frqs] = twt(ts,EEG.srate, scales, 5);

for i=1:nsegments
    istart = (i-1)*window+1;
    iend = i*window;
    wts(:,:,i) = wt(:,istart:iend);
end

[mp ms] = cross_freq_mod(wts);

text = sprintf('MS_SMA %s ch%d', cond, ch);

if (bs)
    [pinc] = ms_SMA_bs(ms, ts, EEG.srate, window, aparams);
    sig = FDR_corr_pop(pinc, alpha);
    cpinc = sig.*ms;
    
    h = figure(1);
    set(h, 'Name', text);
    plot_cfmodulation(mp, ms, aparams, frqs, [0 0.05]);
    save_figure(h,eDir, text);
    
    h = figure(2);
    set(h, 'Name', [text 'MP Significance']);
    plot_cfmodulation([], cpinc, aparams, frqs, [0 0.05]);
    save_figure(h,eDir, [text 'MP Significance']);
    save([eDir text 'MP Significance' '.mat'], 'ms', 'mp', 'sig');
else
    h = figure(1);
    set(h, 'Name', text);
    plot_cfmodulation([], ms, aparams, frqs, [0 0.05]);
    save_figure(h,eDir, text);
    save([eDir text '.mat'], 'ms', 'mp');
end

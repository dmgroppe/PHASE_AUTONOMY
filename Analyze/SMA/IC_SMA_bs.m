% USAGE: analyze_SMA(EEG, cond, frange, atype, length, alpha)
%
%   Computes the syn matrix according to various type of measures of
%   synchrony
%   Return: sync matrix, and significance if computed

function [sync sig] = IC_SMA_bs(EEG, cond, frange, atype, slength, alpha, bs)
tic

if nargin < 7; bs = 0; end; % default to 60s of data
if nargin < 6; alpha = .005; end;
if nargin < 5; slength = 60; end; % default to 60s of data

% Region of interest( positive mapping sites)
roi = [7 8 15 16 59 60 61];
nfig = 1;

[eDir] = get_export_path_SMA();
[tstart tend] = get_trange(cond, slength);

aparams = get_default_params();

aparams.ana.nsurr = 1000;
aparams.sync.lowcut = frange(1);
aparams.sync.highcut = frange(2);

fprintf('\nStarting: %s\n',datestr(now));
fprintf('%s %4.0f-%4.0fHz %s alpha %6.4f\n', upper(cond),...
            aparams.sync.lowcut, aparams.sync.highcut, upper(atype), alpha);
        
subr = get_subregion(EEG, tstart, tend);
subr = subr(1:EEG.nbchan-1,:);

[sync hs] = sync_matrix(subr, EEG.srate, aparams, atype);

%  Lots of noise on these two channels which spuriously exaggerates
%  the calculation for this pair
sync(32,23) = 0;

if (bs)
    fprintf('Performing bootstrap statistics...\n');
    [pinc pdec] = BS_sync(sync, hs, atype, aparams);
    [sig_inc, pcut] = FDR_corr_pop(pinc, alpha);
    fprintf('pinc = %e\n', pcut);
    [sig_dec, pcut] = FDR_corr_pop(pdec, alpha);
    fprintf('pdec = %e\n', pcut);

    csig = (sig_inc + sig_dec).*abs(sync);
 
    h = figure(nfig);
    text = sprintf('%s %4.0f-%4.0fHz %s BS Significance alpha %3.0e', upper(cond),...
        aparams.sync.lowcut, aparams.sync.highcut, upper(atype), alpha);
    set(h, 'Name', text);

    plot_syncmatrix(csig, [0 0.5]);

    title(text);
    save_figure(h,eDir, text);
    
    R = sort_to_regions(csig, roi);
    show_region_summary(R);
    save([eDir text ' Results.mat'], 'atype', 'frange', 'cond', 'pinc', 'pdec', 'sync');

else
    h = figure(nfig);
    text = sprintf('%s %4.0f-%4.0fHz %s', upper(cond),...
        aparams.sync.lowcut, aparams.sync.highcut, upper(atype));
    set(h, 'Name', text);
    plot_csig(sync, atype);
    title(text);
    save_figure(h,eDir, text);
    sig = 1;
end

toc

function plot_csig(csig, atype)

switch atype
    case 'pc'
        caxis_range = [0 0.5764];
        plot_syncmatrix(csig, caxis_range);
    case 'wpli'
        caxis_range = [-0.6 0.6];
        plot_syncmatrix(csig, caxis_range);
    case 'corr'
        caxis_range = [-.0306 0.3304];
        plot_syncmatrix(csig, caxis_range);
    otherwise
        plot_syncmatrix(csig);
end
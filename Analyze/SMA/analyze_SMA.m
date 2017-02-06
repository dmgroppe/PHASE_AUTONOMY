% USAGE: analyze_SMA(EEG, cond, frange, atype, length, alpha)
%
%   Computes the syn matrix according to various type of measures of
%   synchrony
%   Return: sync matrix, and significance if computed

function [sync sig] = analyze_SMA(EEG, cond, frange, atype, ptname, slength, alpha, bs, surr)
tic

if nargin < 9; surr = 0; end;
if nargin < 8; bs = 0; end; % default to 60s of data
if nargin < 7; alpha = .005; end;
if nargin < 6; slength = 60; end; % default to 60s of data
if nargin < 5; ptname = 'vant'; end;

doabs = 0;
roi = [7 8 15 16 59 60 61];

nfig = 1;

[eDir] = get_export_path_SMA();
[tstart tend] = get_trange(cond, slength, ptname);

aparams = get_default_params();
aparams.ana.nsurr = 200;
aparams.sync.lowcut = frange(1);
aparams.sync.highcut = frange(2);

ap = sync_params();

% Set corr window to half the sampling rate
aparams. corrwindow = EEG.srate/2;

fprintf('\nStarting: %s\n',datestr(now));
fprintf('%s %4.0f-%4.0fHz %s alpha %6.4f\n', upper(cond),...
            aparams.sync.lowcut, aparams.sync.highcut, upper(atype), alpha);
        
subr = get_subregion(EEG, tstart, tend);
subr = subr(1:EEG.nbchan-1,:);

% If surrogate generation then time shift each of the channels
if surr
    display('Surrogate generation has been selected...')
    for i=1:size(subr,1)
        subr(i,:) = rand_rotate(subr(i,:));
    end
end

% P is a matrix of proababilities as some of the analyses return
% probabilities for the syncs (ie. spcorr)
[sync hs, P] = sync_matrix(subr, EEG.srate, aparams, atype);

switch atype
    case 'ic'
        fprintf('   Computing statistics\n');
        stddev = imagco_stddev(sync);
        p = 1-normcdf(abs(sync), 0, stddev);
        [sig pcut] = FDR_corr_pop(p, alpha);
        fprintf('p = %e\n', pcut);
        
        % colorize the significance matrix with the sync matrix
        %csig = sig.*abs(sync);
        if (doabs)
            csig = sig.*abs(sync);
        else
            csig = sig.*sync;
        end
        h = figure(nfig);
        text = sprintf('%s %4.0f-%4.0fHz IC Significance alpha %3.0e', upper(cond),...
            aparams.sync.lowcut, aparams.sync.highcut, alpha);
        set(h, 'Name', text);  
        
        plot_syncmatrix(csig, ap.yaxis);
         
        title(text);
        save_figure(h, eDir, text);
        
        R = sort_to_regions(csig, roi);
        show_region_summary(R);
        save([eDir text ' Regions.mat'], 'R');
        %[G] = graph_analysis(csig)
    case 'spcorr'
        [sig pcut] = FDR_corr_pop(P, alpha);
        if (doabs)
            csig = sig.*abs(sync);
        else
            csig = sig.*sync;
        end
        
        h = figure(nfig);
        text = sprintf('%s %4.0f-%4.0fHz SPCORR Significance alpha %3.0e', upper(cond),...
            aparams.sync.lowcut, aparams.sync.highcut, alpha);
        set(h, 'Name', text);
        
%         if (doabs)
%             plot_syncmatrix(csig, [0 0.3]);
%         else
%             plot_syncmatrix(csig, [-0.3 0.3]);
%         end

        plot_syncmatrix(csig, []);
        
        title(text);
        save_figure(h, eDir, text);        
        
    otherwise
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
            
            % colorize the significance matrix with the sync matrix
            if (min(min(sync)) < 0)
                csig = (sig_inc + sig_dec).*sync;
            else
                csig = sig_inc.*sync;
            end

            h = figure(nfig);
            text = sprintf('%s %4.0f-%4.0fHz %s BS Significance alpha %3.0e', upper(cond),...
                aparams.sync.lowcut, aparams.sync.highcut, upper(atype), alpha);
            set(h, 'Name', text);
      
            plot_csig(csig, atype);
            
            title(text);
            save_figure(h,eDir, text);
            R =  sort_to_regions(csig, roi);
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
function [R] = processSingle(sz_name, cfg, plot_figs)

global DATA_DIR;

if nargin < 3; plot_figs = 1; end;

plotdataonly = 0;


% Get the defaults for analysis

R = [];
%cfg = cfg_default()
sdir = strtok(sz_name, '_');


dp = fullfile(DATA_DIR,'Szprec', sdir, 'Data');
pp = fullfile(DATA_DIR,'Szprec', sdir, 'Processed', [sz_name '_F']);

dfile = fullfile(dp,[sz_name '.mat']);
if ~exist(dfile, 'file')
    display(dfile);
    display('Data file not found');
    return;
end
    
load(dfile);

% select the type of channel to use for analyses
d = Szprec_sel_data(matrix_mo, matrix_bi, cfg);

if cfg.use_fband
    h = figure;clf;
    fname = [sz_name '-F_FBAND'];
    set(h, 'Name', fname);
    display(sprintf('Computing FBAND analyses for file - %s',sz_name));

    [F, rank] = Sprec_bandpass(d, Sf, cfg, sdir, 1);
    save_figure(h,pp, fname, false);
    % Save the precursor and all associated data
    save(fullfile(pp, [fname '.mat']), 'F', 'Sf', 'cfg', 'matrix_bi',...
        'matrix_mo', 'group_end_index', 'rank', 'sz_name');
    saveas(h,fullfile(pp, [fname '.fig']));

    [R] = struct_from_list('F', F, 'Sf', Sf, 'cfg', cfg, 'matrix_bi', matrix_bi,...
        'matrix_mo', matrix_mo,'group_end_index', group_end_index, 'rank', rank, 'sz_name', sz_name);
else
    if ~plotdataonly
        display(sprintf('Computing precursor for file - %s',sz_name));

        % Compute the precursor
        switch cfg.analysis
            case 'phase_coherence'
                afunc = @Szprec_phase_coherence_fun;
            case 'desync'
                afunc = @Szprec_prec_fun;
            case 'variance'
                afunc = @Szprec_prec_fun;
        end
        tic
        [F, ~] = F_chan_list_1(afunc, d, Sf, cfg);
        toc

        % Save the MATLAB figure
         % Chrck to see if the 'processed' director exists
        if ~exist(fullfile(pp), 'dir')
            mkdir(fullfile(pp));
        end

        % Plot the precursor and save the figure
        if plot_figs
            h = figure(1); clf;
            plot_f_multichan(F,Sf, cfg, sdir);
            save_figure(h,pp, [sz_name '-F'], false);
        end

        %saveas(h,[pp files(j).name(1:(end-4)) '-F'], 'fig');

        % Save the precursor and all associated data
        save_file = fullfile(pp, [sz_name '_F.mat']);
        if exist('group_end_index', 'var')
            save(save_file, 'F', 'Sf', 'cfg', 'matrix_bi',...
                'matrix_mo', 'group_end_index');
            [R] = struct_from_list('F', F, 'Sf', Sf, 'cfg', cfg, 'matrix_bi', matrix_bi,...
                'matrix_mo', matrix_mo,'group_end_index', group_end_index, 'sz_name', sz_name);
        else
            save(save_file, 'F', 'Sf', 'cfg', 'matrix_bi',...
                'matrix_mo');
            [R] = struct_from_list('F', F, 'Sf', Sf, 'cfg', cfg, 'matrix_bi', matrix_bi,...
                'matrix_mo', matrix_mo,'sz_name', sz_name);
        end
    end

    % Plot and save the data traces
    if plot_figs
        h = figure(2);clf;
        Szprec_tf(d, Sf, cfg, sdir);
    end
    %save_figure(h,pp, [files(j).name(1:(end-4)) '-DATA'], false);

    % Save the data MATLAB figure
    %saveas(h,[pp '\\' files(j).name(1:(end-4)) '-DATA'], 'fig');
end


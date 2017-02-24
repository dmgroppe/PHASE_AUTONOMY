function [R] = Szprec_process(sdir)
%function [R] = Szprec_process(sdir)
%
% Input:
%  sdir - cell array of case codenames (e.g., {'AB','ST'}
%
% Output:
%   R -
%
% Computes phase fluctuations at 6 frequency bands for all channels and
% makes some figures

global DATA_DIR;

plotdataonly = 0;

% Get the defaults for analysis

cfg = cfg_default()

% DG hack ??
warning('DG is using some hard coded cfg values to replicate old results. The cfg values are not the most current.');
cfg.useFilterBank=1;
cfg.stats.sm_window=0.5;
cfg.exclude_bad_channels=0;
cfg.f_caxis=[]; 
%load('/Users/dgroppe/ONGOING/TWH_DATA/Szprec/NA/Processed/NA_d1_sz2_F/NA_d1_sz2_F_TVworks.mat','cfg');


for i=1:numel(sdir)
    dp = fullfile(DATA_DIR,'Szprec',sdir{i}, 'Data');
    pp = fullfile(DATA_DIR, 'Szprec',sdir{i}, 'Processed');
    %     dp = fullfile(DATA_DIR,'Szprec', sdir{i}, 'Data'); DG commented
    %     out
    %     pp = fullfile(DATA_DIR,'Szprec', sdir{i}, 'Processed'); DG commented
    %     out
    
    files = dir(fullfile(dp, '*.mat'));
    if ~isempty(files)
        for j=1:numel(files)
            load(fullfile(dp,files(j).name));
            sz_name = files(j).name;
            nchan = size(matrix_bi,2);
            
            % select the type of channel to use for analyses
            d = Szprec_sel_data(matrix_mo, matrix_bi, cfg); %d is the raw data
            
            if cfg.use_fband % FALSE is default
                h = figure;clf;
                fname = [files(j).name(1:(end-4)) '-F_FBAND'];
                set(h, 'Name', fname);
                display(sprintf('Computing FBAND analyses for file - %s',files(j).name(1:(end-4))));
                              
                [F, rank] = Sprec_bandpass(d, Sf, cfg, sdir{i}, 1);
                save_figure(h,pp, fname, false);
                % Save the precursor and all associated data
                save(fullfile(pp, [fname '.mat']), 'F', 'Sf', 'cfg', 'matrix_bi',...
                    'matrix_mo', 'group_end_index', 'rank', 'sz_name');
                saveas(h,fullfile(pp, [fname '.fig']));
                
                [R] = struct_from_list('F', F, 'Sf', Sf, 'cfg', cfg, 'matrix_bi', matrix_bi,...
                    'matrix_mo', matrix_mo,'group_end_index', group_end_index, 'rank', rank, 'sz_name', sz_name);
            else
                if ~plotdataonly
                    display(sprintf('Computing precursor for file - %s',files(j).name(1:(end-4))));

                    % Compute the precursor
                    switch cfg.analysis % desync is default
                        case 'phase_coherence'
                            afunc = @Szprec_phase_coherence_fun;
                        case 'desync'
                            afunc = @Szprec_prec_fun;
                    end
                    tic
                    [F, ~] = F_chan_list_1(afunc, d, Sf, cfg);
                    toc
%                     if ~cfg.bigmem
%                         switch cfg.analysis
%                             case 'phase_coherence'
%                                 afunc = @precursor;
%                             case 'desync'
%                                 afunc = @precursor;
%                         end
%                         F = f_multichan(afunc, d, Sf, 1:nchan, 1:nchan, cfg);
%                     else
%                         switch cfg.analysis
%                             case 'phase_coherence'
%                                 afunc = @Szprec_phase_coherence_fun;
%                             case 'desync'
%                                 afunc = @Szprec_prec_fun;
%                         end
%                         [F, ~] = F_chan_list_1(afunc, d, Sf, cfg);
%                     end
%                     toc
                    
                    % Save the MATLAB figure
                     % Check to see if the 'processed' director exists
                    if ~exist(fullfile(pp), 'dir')
                        mkdir(fullfile(pp));
                    end
                    
                    % Create a new dir for F results (DG change)
                    f_dir=fullfile(pp,[files(j).name(1:(end-4)) '_F']);
                    if ~exist(fullfile(f_dir), 'dir')
                        mkdir(fullfile(f_dir));
                    end
                    
                    % Plot the precursor and save the figure
                    h = figure(1); clf;
                    plot_f_multichan(F,Sf, cfg, sdir{i});
                    %ORIG save_figure(h,pp, [files(j).name(1:(end-4)) '_F'], false);
                    save_figure(h,f_dir, [files(j).name(1:(end-4)) '_F'], false);
                    
                    %saveas(h,[pp files(j).name(1:(end-4)) '-F'], 'fig');

                    % Save the precursor and all associated data
                    %ORIG save_file = fullfile(pp, [files(j).name(1:(end-4)) '_F.mat']);
                    save_file = fullfile(f_dir, [files(j).name(1:(end-4)) '_F.mat']);
                    fprintf('Saving file to %s\n',save_file);
                    if exist('group_end_index', 'var')
                        save(save_file, 'F', 'Sf', 'cfg', 'matrix_bi',...
                            'matrix_mo', 'group_end_index');
                        [R] = struct_from_list('F', F, 'Sf', Sf, 'cfg', cfg, 'matrix_bi', matrix_bi,...
                            'matrix_mo', matrix_mo,'group_end_index', group_end_index, 'sz_name', sz_name);
                    else
                        save(save_file, 'F', 'Sf', 'cfg', 'matrix_bi',...
                            'matrix_mo','sz_name', sz_name);
                        [R] = struct_from_list('F', F, 'Sf', Sf, 'cfg', cfg, 'matrix_bi', matrix_bi,...
                            'matrix_mo', matrix_mo,'sz_name', sz_name);
                    end
                end

                % Plot and save the data traces
                h = figure(2);clf;
                Szprec_tf(d, Sf, cfg, sdir{i});
                %save_figure(h,pp, [files(j).name(1:(end-4)) '-DATA'], false);
                
                % Save the data MATLAB figure
                %saveas(h,[pp '\\' files(j).name(1:(end-4)) '-DATA'], 'fig');
            end
        end
    end
end
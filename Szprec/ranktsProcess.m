function [] = ranktsProcess(sdir, dosave, a_cfg)

if nargin <2; dosave = 1; end;
if nargin <3; a_cfg = cfg_default(); end;

freqs_to_process = [6 10 20 30 60 100];

global DATA_DIR;

for i=1:numel(sdir)
    dp = fullfile(DATA_DIR, 'Szprec', sdir{i}, 'Processed');
    dd = fullfile(DATA_DIR, 'Szprec', sdir{i}, 'Data');
    files = dir(fullfile(dd,'*.mat'));
    if ~isempty(files)
        for j=1:numel(files)
            % Load the precursor file.  Some of them include the data too
            prec_dir = fullfile(DATA_DIR, 'Szprec', sdir{i}, 'Processed', [files(j).name(1:end-4) '_F']);
            prec_file = fullfile(prec_dir, [files(j).name(1:end-4) '_F.mat']); 
            if exist(prec_file, 'file');
                load(prec_file);
                display(sprintf('Ranking %s', files(j).name(1:end-4)));
   
                % Load the data for this file.  Some of the precursor files
                % have the data in it too in that case just skip over this.
                if ~exist('matrix_bi', 'var');
                    load([dd files(j).name(1:end-6) '.mat']);
                end

                % This is to accomodate older analysis that used the bipolar
                % specification as a boolean

                if ~isfield(cfg, 'chtype')
                    if cfg.usebipolar
                        cfg.chtype = 'bipolar';
                    else
                        cfg.chtype = 'monopolar';
                    end
                end


                % Process all the frequencies if not specified - this will take
                % a long time
                if isempty(freqs_to_process)
                    freqs_to_process = cfg.freqs;
                end

                %Select the data to display
                d = Szprec_sel_data(matrix_mo, matrix_bi, cfg);

                h = figure(1);clf;
                if a_cfg.rank_across_freqs
                    [~, ax] = Szprec_rankts(F, Sf, cfg, a_cfg, 0, sdir{i}, 4);
                    fname = sprintf('All freqs - %s', files(j).name(1:end-4));
                    set(h, 'Name', fname);

                    %plot the data on the same figure                  
                    plot_data(d, Sf, cfg, ax, sdir{i});
                    drawnow;
                    
                    if dosave

                        save_figure(h, prec_dir, fname, false);

                        % Save the figure file for later viewing
                        saveas(h,fullfile(prec_dir, [fname '.fig']));
                    end
                else
                    % Process each frequency
                    for k=1:length(freqs_to_process);
                        [isokay, ax] = Szprec_rankts(F, Sf, cfg, a_cfg, freqs_to_process(k), sdir{i}, 4);
                        if isokay
                            fname = sprintf('%dHz - %s', freqs_to_process(k), files(j).name(1:end-4));
                            set(h, 'Name', fname);

                            %plot the data on the same figure                  
                            plot_data(d, Sf, cfg, ax, sdir{i});
                            drawnow;
                            if dosave
                                save_figure(h, prec_dir, fname, false);

                                % Save the figure file for later viewing
                                saveas(h,fullfile(prec_dir, [fname '.fig']));
                            end
                        end
                    end
                end
            else
                display(prec_file);
                display('Unable to load this file.')
            end
        end
    end
end

function [] = plot_data(d, Sf, cfg, ax, sdir)
ax(length(ax)+1) = subplot(4,1,[3 4]);

new_ax = Szprec_tf(d, Sf, cfg, sdir);
title(upper(cfg.chtype));
set(gca, 'TickDir' , 'out');
linkaxes([ax new_ax], 'xy');
function [] = Szprec_process_fband(sdir)

global DATA_DIR;

% Get the defaults for analysis

cfg = cfg_default()

% Make sure to set this other wise it will not run properly
cfg.use_fband = 1;
a_cfg = cfg;

if min(size(cfg.fband)) == 1
    nf_bands = 1;
else
    nf_bands = size(cfg.fband,2);
end

for i=1:numel(sdir)
    dp = fullfile(DATA_DIR,'Szprec', sdir{i}, 'Data');
    pp = fullfile(DATA_DIR,'Szprec', sdir{i}, 'Processed');

    files = dir(fullfile(dp, '*.mat'));
    if ~isempty(files)
        for j=1:numel(files)
            load(fullfile(dp,files(j).name));
            
          % select the type of channel to use for analyses
            d = Szprec_sel_data(matrix_mo, matrix_bi, cfg);
            
            for f=1:nf_bands
                if nf_bands == 1
                    a_cfg.fband = cfg.fband;
                else
                    a_cfg.fband = cfg.fband(:,f);
                end
                
                % Make sure the specified fband is not greater than half
                % the Nyquist frequency
                
                if a_cfg.fband(2) >= Sf/2
                    a_cfg.fband(2) = Sf/2-5;
                end
                
                h = figure(1);clf;
                fname = [files(j).name(1:(end-4)) '_F_FBAND'];
                sz_dir = fullfile(pp,fname);
                
                if ~exist(sz_dir, 'dir')
                    mkdir(sz_dir)
                end
                
                fname = sprintf('%s_%d_%dHz',[files(j).name(1:(end-4)) '_F_FBAND'], a_cfg.fband(1), a_cfg.fband(2));
                set(h, 'Name', fname);
                display(sprintf('Computing FBAND analyses for file - %s: %d-%dHz',...
                    files(j).name(1:(end-4)),a_cfg.fband(1), a_cfg.fband(2)));
                
                switch a_cfg.analysis
                    case 'phase_coherence'
                        afunc = @Szprec_phase_coherence_fun;
                    case 'desync'
                        afunc = @Szprec_prec_fun;
                end
             
                [F{f}, ~] = Sprec_fband(afunc, d, Sf, a_cfg, sdir{i}, 1, 1);

                save_figure(h,sz_dir, fname, false);
                saveas(h,fullfile(sz_dir, [fname '.fig']));
            end
            
            % Save the precursor and all associated data
            fname = [files(j).name(1:(end-4)) '_F_FBAND'];
            save(fullfile(sz_dir, [fname '.mat']), 'F', 'Sf', 'cfg', 'matrix_bi', 'matrix_mo');
        end
    end
end


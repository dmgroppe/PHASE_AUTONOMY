function [ap] = autocoh_params(ap, ptname, ch)

% Parameters common to all analyses
ap.autocoh.nsurr = 1;
ap.autocoh.use_periodic = false;
ap.autocoh.periodic.nperm = 100;
ap.autocoh.useall = false;
ap.autocoh.check_fit = false;
ap.autocoh.periodic.fwindow = [60 200];

switch ptname
    case 'vant'
        % Common parameters to both analysis and burst Simulation
        ap.autocoh.dt = 0.050;  % Width of the Gabor atom to use for transform
        ap.autocoh.blength = []; % Maximal burst length, set to [] for all lengths
        ap.autocoh.minlength = 0;
        ap.autocoh.use_cv = true; % Use the CV to determine burst autocoherence
        ap.autocoh.cv = 0.05; % Value to use id using CV for AC
        ap.autocoh.decorr_angle = pi/4;
        ap.autocoh.bsize = 2;
        ap.autocoh.prob_bin = 5;
        ap.autocoh.prob_maxburstlength = .200;
        ap.autocoh.prob_minburstlength = 0;
        ap.autocoh.prob_caxis = [0 0.05];
        ap.autocoh.minbursts = 50;
        
        % Periodic analysis  
        ap.autocoh.periodic.frange = [125 165];
        ap.autocoh.periodic.fwindow = [125 165];
        
        switch ch
            % Channel specific parameters
            case 8
                ap.autocoh.freq_add = [100 135];
                ap.autocoh.amp_scale = [2.5 2];
                %ap.autocoh.amp_scale = [2.5 2];
                ap.autocoh.bfrac = [0.2 0.2];
                ap.autocoh.t_scale = [8 12];
                ap.autocoh.tol = 1e-3;
                ap.autocoh.olap = 0.2;
            case 60
                ap.autocoh.freq_add = [100 135];
                ap.autocoh.amp_scale = [2.5 2];
                %ap.autocoh.amp_scale = [2.5 2];
                ap.autocoh.bfrac = [0.2 0.2];
                ap.autocoh.t_scale = [8 12];
                ap.autocoh.tol = 1e-3;
                ap.autocoh.olap = 0.2;
            otherwise
                error('No specification for the specified channel found');
        end
    case 'nourse'
        % Common parameters to both analysis and burst Simulation
        ap.autocoh.dt = 0.050;  % Width of the Gabor atom to use for transform
        ap.autocoh.blength = []; % Maximal burst length, set to [] for all lengths
        ap.autocoh.minlength = 0;
        ap.autocoh.use_cv = true; % Use the CV to determine burst autocoherence
        ap.autocoh.cv = 0.05; % Value to use id using CV for AC
        ap.autocoh.decorr_angle = pi/4;
        ap.autocoh.bsize = 1.5; % Burst size in Z-units
        ap.autocoh.prob_bin = 5;
        ap.autocoh.prob_maxburstlength = .200;
        ap.autocoh.prob_minburstlength = 0;
        ap.autocoh.prob_caxis = [0 0.05];
        
        % Periodic analysis      
        ap.autocoh.periodic.frange = [111 127];

         % Channel specific parameters
        switch ch
            case 8
                ap.autocoh.freq_add = [120];
                %ap.autocoh.amp_scale = [20];
                ap.autocoh.amp_scale = [2.65];
                %ap.autocoh.amp_scale = [20.65];
                ap.autocoh.t_scale = [16];
                ap.autocoh.tol = 1e-3;
                ap.autocoh.olap = -7.0;
                ap.autocoh.minbursts = 0;
            case 5
                ap.autocoh.freq_add = [120];
                ap.autocoh.amp_scale = [1.8];
                ap.autocoh.bfrac = [0.2];
                ap.autocoh.t_scale = [20];
                ap.autocoh.tol = 1e-3;
                ap.autocoh.olap = -8.0;
                ap.autocoh.minbursts = 0;
            case 16
                ap.autocoh.freq_add = [120];
                ap.autocoh.amp_scale = [2.65];
                ap.autocoh.bfrac = [0.2];
                ap.autocoh.t_scale = [16];
                ap.autocoh.tol = 1e-3;
                ap.autocoh.olap = -7.0;
                ap.autocoh.minbursts = 0;
            case 13
                ap.autocoh.freq_add = [120];
                ap.autocoh.amp_scale = [1.8];
                ap.autocoh.bfrac = [0.2];
                ap.autocoh.t_scale = [20];
                ap.autocoh.tol = 1e-3;
                ap.autocoh.olap = -8.0;
                ap.autocoh.minbursts = 0;
            otherwise
                error('No specification for the specified channel found');
        end
         
end
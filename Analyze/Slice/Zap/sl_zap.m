function [R] = sl_zap(dap, doplot)

% Function to compute power spectra from regions of an ABF file
% specified by the user.  Any number of regions can be specified in the 'ap'
% parameter structure.  Each region must have an associated label with it.

% Set some defaults

ap = sl_sync_params();

if nargin < 2; doplot = 0; end;

% Set default values
R.sp_freqs = [];
R.Z = [];
R.w = [];
R.zap_peak_edges = [];
R.isSpiking = [];
R.Z_interp = [];
R.w_inter = [];

% Make sure it all the files exist
[fpaths, path_okay] = check_files(dap, '.abf');

if ~path_okay
    display(sprintf('Exiting %s.', mfilename()));
    return;
end

R = zap_process(dap, fpaths{1}, dap.cond.fname{1}, doplot, ap.zap.tfactor, ap.zap.i_amp,...
    ap.zap.threshold, ap.zap.frange, ap.zap.interp_w);

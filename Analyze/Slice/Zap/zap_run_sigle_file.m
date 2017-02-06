function [R] = zap_run_sigle_file(Dir, fn, ap)

if nargin < 3; ap = sl_sync_params(); end;

R = zap_process(ap, Dir, fn, 1, ap.zap.tfactor, ap.zap.i_amp,...
    ap.zap.threshold, ap.zap.frange, ap.zap.interp_w);
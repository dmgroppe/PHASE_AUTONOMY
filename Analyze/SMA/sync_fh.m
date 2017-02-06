function [fh] = sync_fh(atype)

switch atype
    case 'pc'
        fh = @phase_coherence;
    case 'pl'
        fh = @pl;
    case 'ic'
        fh = @imag_coherence;
    case 'aic'
        fh = @aimag_coherence;
    case 'corr'
        fh = @aec;
    case 'acorr'
        fh = @acorr;
    case 'coh'
        fh = @coherence_nogpu;
    case 'pli'
        fh = @pli;
    case 'dbswpli'
        fh = @dbswpli;
    case 'wpli'
        fh = @wpli;
    case 'plv'
        fh = @Phase_locking_value;
    case 'pcm'
        fh = @pcm;
end
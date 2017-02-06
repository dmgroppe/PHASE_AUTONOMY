function [d] = Szprec_sel_data(matrix_mo, matrix_bi, cfg)

switch cfg.chtype
    case 'bipolar'                    
        d = matrix_bi;
    case 'monopolar'
        d = matrix_mo;
    case 'car'
        d = matrix_mo;
        d = remove_nans(d);
        d = Szprec_common_average_reference(d, cfg.ch_to_excl);
    otherwise
        display('Incorrect channel type specification, defaulting to bipolar');
        d = matrix_bi;
end
function [eh_b eh_m] = BH_electrode_hack(sz_name)

 p = textscan(sz_name, '%s', 'Delimiter','_');
 d = textscan(p{1}{2},'d%d');
 
 switch d{1}
     case 1
         m_labels = mono_labels('LHD', 4, 'LAT', 4, 'LMT', 4, 'LPT', 4, 'LLF', 4, ...
           'LOFP', 6, 'RHD', 4, 'RAT', 4, 'RMT', 4, 'RPT', 4, 'RLF', 4, 'ROFP', 6);
       [old_blabels, ~] = get_channels_with_text('BH', [], 'bipolar');
       [old_mlabels, ~] = get_channels_with_text('BH', [], 'mono');
       [new_blabels, ~] = bipolar_labels([4 8 12 16 20 26 30 34 38 42 46 52], m_labels);
       eh_b = get_indicies(old_blabels, new_blabels);
       eh_m = get_indicies(old_mlabels, m_labels);
     otherwise
         eh_b = [];
         eh_m = [];
         
 end
 

function [t] = get_indicies(old_b_names, new_b_names)

for i=1:numel(new_b_names)
    ind = find_text(old_b_names, new_b_names(i));
    t(i) = ind;
end


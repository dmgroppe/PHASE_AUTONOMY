function [pfcorr] = run_pfcorr()

pt_names = {'NA', 'AV', 'MSt', 'SP', 'CT', 'ME', 'SV'};

parfor i=1:numel(pt_names)
    pfcorr{i} = Szprec_ph_tf(pt_names{i}, 0);
end
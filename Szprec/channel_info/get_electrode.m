function [e] = get_electrode(pt_name)

func_name = sprintf('%s_electrodes', pt_name);
fh = str2func(func_name);
e = feval(fh);

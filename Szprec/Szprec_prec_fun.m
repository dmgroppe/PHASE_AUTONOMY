function [F] = Szprec_prec_fun(wt, i1, srate, cfg)

% Precursor function

switch cfg.analysis
    case 'desync'
        afunc = @precursor;
    case 'variance'
        afunc = @precursor_var;
end

if length(size(wt)) == 2
    nchan = size(wt,2);
    F = zeros(size(wt,1), nchan-i1);
    c = 0;
    for j=(i1+1):nchan
        c = c+1;
        F(:,c) = afunc(wt(:,i1), wt(:,j), srate, cfg);
    end
else
    nchan = size(wt,3);
    F = zeros(size(wt,1), size(wt,2), nchan-i1);
    c = 0;
    for j=(i1+1):nchan
        c = c+1;
        if max(max(wt(:,:,i1))) ~= 0 && max(max(wt(:,:,j))) ~= 0
            F(:,:,c) = afunc(wt(:,:,i1), wt(:,:,j), srate, cfg);
        end
    end
end



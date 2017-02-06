function [bursts, ac_count] = autocoh(Z,phi,freqs,ranges,ap, srate)

if ~isempty(ap.autocoh.blength)
    blength = fix(ap.autocoh.blength*srate);
else
    blength = 0;
end

nfreqs = size(Z,1);
minlength = fix(ap.autocoh.minlength*srate); 
T = 1./freqs;

for i=1:nfreqs
    % Go through each burst for each frequency
    for j=1:size(ranges{i},2)
        p = phi(i,ranges{i}(1,j):ranges{i}(2,j));
        dts = (ranges{i}(1,j):ranges{i}(2,j))/srate;
        
        % Correct the phase angle of the burst, and make it from 0 to 2pi
        %p_corr = 2*mod(p - 2*pi*mod(dts,T)/T, pi);
        p_corr = phase_diff(p - 2*pi*mod(dts,T(i))/T(i));
        ac.p_corr = p_corr;
        ac.a = Z(i,ranges{i}(1,j):ranges{i}(2,j));
        
        if blength
            if length(p_corr) > blength
                %p_corr_stat = p_corr(1:blength);
                p_corr_stat = p_corr((end-blength):end);
            else
                p_corr_stat = p_corr;
            end
        else
            p_corr_stat = p_corr;
        end     
        
        if ap.autocoh.use_cv
            rho_p = circ_var(p_corr);
            if rho_p > ap.autocoh.cv
                ac.is_ac = false;
            else
                ac.is_ac = true;
            end
        else             
            if abs((max(p_corr_stat) - min(p_corr_stat))) <= ap.autocoh.decorr_angle...
                    && length(p_corr_stat) >= minlength
                ac.is_ac = true;
            else
                ac.is_ac = false;
            end
        end
        bursts{i}(j) = ac;
    end
    ac_count(i) = sum([bursts{i}.is_ac] == true);
end
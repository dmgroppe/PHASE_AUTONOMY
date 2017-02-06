function [ranges, new_sig] = sig_to_ranges(sig, freqs, minr)

minr_c = minr/(freqs(2)-freqs(1))+1;
sig_index = find(sig ==1);
ranges = [];
new_sig = sig;

if length(sig_index) < minr_c
    new_sig(:) = 0;
    return;
end


rstart = 1;
count = 0;
new_sig(:,:) = 0; 

while (rstart < length(sig_index)-1)
    for j=rstart:length(sig_index)-1
        if sig_index(j+1) ~= sig_index(j)+1
            rend = j;
            break;
        else
            rend = j+1;
        end
    end
    
    if rstart ~= rend && (rend - rstart+1)>= minr_c
        count = count + 1;
        ranges(:,count) = [sig_index(rstart) sig_index(rend)];
        
        % Make a new sig to return
        new_sig(sig_index(rstart):sig_index(rend)) = 1;
    end
    rstart = rend+1;
    rend = rstart;
end

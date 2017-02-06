function [index] = get_f_index(f, w)

index = find(f == w, 1);

if (isempty(index))
    for i=2:length(w)
        if (f >= w(i-1) && f <= w(i))
            if ( (f - w(i-1)) < (w(i) - f))
                index = i-1;
                return;
            else
                index = i;
                return;
            end
        end
    end
end
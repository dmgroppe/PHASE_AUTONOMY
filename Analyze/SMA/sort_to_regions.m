function [R] = sort_to_regions(sig, electrodes)

nchan = length(sig);

R.within_num = 0;
R.out_num = 0;
R.between_num = 0;
R.total_num = 0;
R.within_c = [];
R.out_c = [];
R.between_c = [];

for i=1:nchan
    for j=i+1:nchan
        if abs(sig(j,i)) > 0
            R.total_num = R.total_num + 1;
            R.all_c(:, R.total_num) = [j,i];
            if (~isempty(find(electrodes == i, 1)) && ~isempty(find(electrodes == j, 1)))
                % Electrode pairs ONLY with region of interest
                R.within_num = R.within_num + 1;
                R.within_c(:, R.within_num) = [j i];
            elseif (isempty(find(electrodes == i, 1)) && isempty(find(electrodes == j, 1)))
                R.out_num = R.out_num + 1;
                % Electrode pairs that have no direct connections to the
                % electrodes of interest
                R.out_c(:, R.out_num) = [j i];
            elseif ((~isempty(find(electrodes == i, 1)) && isempty(find(electrodes == j, 1))) ||...
                    (isempty(find(electrodes == i, 1)) && ~isempty(find(electrodes == j, 1))))
                % Electrode Pairs with one in the region of interest and
                % one outside
                R.between_num = R.between_num + 1;
                R.between_c(:, R.between_num) = [j i];                
            end
        end
    end
end

% Computes the electrodes that span from the network to the  (unconnected network) 
R.span_num = 0;
was_spanned = 0;
R.spanners_n = 0;
for i=1:R.out_num
    for j = 1:R.between_num
        common_index = find(R.out_c(:,i) == R.between_c(:,j), 1);
        if ( ~isempty(common_index))
            R.span_num = R.span_num + 1;
            was_spanned = 1;
            
            % Take the other index
            if ( common_index == 1)
                other = 2;
            else
                other = 1;
            end
            
            R.span_c(:, R.span_num) = [R.out_c(other,i), R.out_c(common_index,i), R.between_c(other,j)];
        end
    end
    if (was_spanned)
        R.spanners_n = R.spanners_n + 1;
        was_spanned = 0;
    end
end




function [] = maxima_in_ranges(syncs, ap)

ntraces = size(syncs,2);

for i=1:ntraces
    % Find the maxima
    ef1 = ap.freqs(localMaximum(syncs(:,i,1)));
    ef2 = ap.freqs(localMaximum(syncs(:,i,2)));

    for j=1:size(ap.extrema_range,2)
        % Can only have one maximum per freq range, so find if any
        eindex = find(ef1 >= ap.extrema_range(1,j) & ef1 <= ap.extrema_range(2,j));
        if isempty(eindex)
            efreqs1(j,i) = 0;
        else
            efreqs1(j,i) = ef1(eindex(1));
        end

        eindex = find(ef2 >= ap.extrema_range(1,j) & ef2 <= ap.extrema_range(2,j));
        if isempty(eindex)
            efreqs2(j,i) = 0;
        else
            efreqs2(j,i) = ef2(eindex(1));
        end   
    end
end

for j=1:size(ap.extrema_range,2)
    ef1 = find(efreqs1(j,:) > 0);
    ef2 = find(efreqs2(j,:) > 0);
    if ~isempty(ef1) && ~isempty(ef2)
        pstats1 = [mean(efreqs1(j,ef1)) std(efreqs1(j,ef1))/sqrt(length(ef1))];
        pstats2 = [mean(efreqs2(j,ef2)) std(efreqs2(j,ef2))/sqrt(length(ef1))];
        [p ~] = ranksum(efreqs1(j,ef1), efreqs2(j,ef2));
        fprintf('\nMaxima freq range %d - %d\n', ap.extrema_range(1,j), ap.extrema_range(2,j));
        fprintf('%s: mean = %4.0f, sem = %4.2f\n', upper(ap.condlist{1}), pstats1(1), pstats1(2));
        fprintf('%s: mean = %4.0f, sem = %4.2f\n', upper(ap.condlist{2}), pstats2(1), pstats2(2));
        fprintf('p = %e\n', p);
    end
end
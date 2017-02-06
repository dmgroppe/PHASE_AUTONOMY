function [lv] = lv_compute(S, ap)

pend = S.ap.io.pulsedur+ap.io.pulsestart;

for i=1:numel(S.pks)
    for j=1:numel(S.pks{i})
        if ~isempty(S.Pks{i})
            lv(j) = -1;
        else
            if (prod(S.Pks{i} > pend))
                lv(j) = locVar(S.T, S.locs{j}, ap);
            else
                lv(j) = -1;
            end
        end
    end
end


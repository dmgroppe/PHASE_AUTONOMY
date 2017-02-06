function [R] = corr_p_to_f(sm, a_cfg)

nchan = numel(sm.P_mean);

ps = [];
fs = [];
freqs = [];
for i=1:nchan
    if ~isempty(sm.P_mean{i})
        p_norm = sm.P_mean{i}(:,2)./sm.P_mean{i}(:,1);
        f_norm = sm.F_mean{i}(:,2)./sm.F_mean{i}(:,1);
        [~,~,b] = intersect(a_cfg.freqs, a_cfg.stats.ph_tf_freqs);
%         ps = [ps (p_norm(b)/max(p_norm(b)))'];
%         fs = [fs (f_norm/max(f_norm))'];
        ps = [ps zscore(p_norm(b))'];
        fs = [fs zscore(f_norm)'];

        freqs = [freqs a_cfg.freqs];
    end
end

R = struct_from_list('ps', ps, 'fs', fs, 'freqs', freqs);
function [ranking, f_out] = Szprec_rank(F,cfg, a_cfg, sdir)

if a_cfg.exclude_bad_channels
    [bad_m_channels, bad_b_channels] = bad_channels_get(sdir);

    switch cfg.chtype
        case 'bipolar'
            bad_channels = bad_b_channels;
        case 'mono'
            bad_channels = bad_m_channels;
    end
else
    bad_channels = [];
end

f_dim = length(size(F));

% Do the ranking
nchan = size(F,f_dim);
ranking = zeros(length(F),nchan);

for i=1:length(F)
    if f_dim == 3 
        if isfield(cfg, 'analysis')
            if a_cfg.rank_across_freqs
                if strcmpi(cfg.analysis, 'phase_coherence')
                    f = squeeze(max(F(:,i,:),[], 1));
                else 
                    f = squeeze(max(F(:,i,:),[],1));
                end
            else
                f = squeeze(F(ind,i,:));
            end
        else
            f = squeeze(max(F(:,i,:),[],1));
        end
    else
        f = F(i,:)';
    end
    % Set the bad channels to zero
    f(bad_channels) = 0;
    [~, indicies] = sort(f,'descend');
    [~,si] = sortrows(indicies);
    ranking(i,:) = si;
    f_out(i,:) = f;
end

ranking = (nchan - ranking)/(nchan -1);
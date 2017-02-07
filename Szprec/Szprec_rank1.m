function [ranking, f_out] = Szprec_rank1(F,cfg, a_cfg, sdir)
%function [ranking, f_out] = Szprec_rank1(F,cfg, a_cfg, sdir)
% 
% Outputs:
%  ranking - Normalized F rank matrix (time x channel). 0=least F statistic
%          across channels for that time window, 1=highest F statistic across channels for that time
%          window
%
%  f_out - (time x channel matrix) Max F statistic across all frequencies for a particular channel
%          during a particular time window

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


% Take the max phase fluctuation aross all frequencies for each time window
if f_dim == 3 
    if isfield(cfg, 'analysis')
        if a_cfg.rank_across_freqs
            if strcmpi(cfg.analysis, 'phase_coherence')
                f = squeeze(max(F,[], 1));
            else 
                f = squeeze(max(F,[],1));
            end
        else
            f = F;
        end
    else
        f = squeeze(max(F,[],1));
    end
else
    f = F;
end

% This part might not completely work since I only got the dim 3 section
% working, which in fact might be superflous to segregate

if f_dim == 3
    if a_cfg.rank_across_freqs
        f(:,bad_channels) = 0;
        [~, indicies] = sort(f,2,'descend');
        [~,ranking] = sort(indicies,2);
        f_out = f;
    else
        % Not sure if this works.  This is fucked since f_out is going to
        % be per freqeuncy, subsequent plotting assumes f_out is a 2dim
        % matrix
        for i=1:size(F,1) 
            [~, indicies] = sort(squeeze(f(i,:,:),2,'descend'));
            [~,ranking(i,:,:)] = sort(indicies,2);
            f_out = f;
        end
        f(:,:,bad_channels) = 0;
    end
else
    f(:,bad_channels) = 0;
    [~, indicies] = sort(f,2,'descend');
    [~,ranking] = sort(indicies,2);
    f_out = f;
end


ranking = (nchan - ranking)/(nchan -1);
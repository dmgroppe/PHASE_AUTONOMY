function [] = run_BS_SMAstats(EEG)

alpha = .05;
% This does all the IC states and freq ranges

%IC_Bootstrap(EEG)

freqs = 30:5:250;
frange = [freqs(1:end-1)',freqs(2:end)']';

%frange(:,1) = [126 166];
%frange(:,1) = [135 145];
% frange(:,3) = [62 73];
% frange(:,4) = [95 107];
% frange(:,5) = [125 165];
% frange(:,6) = [200 400];

nf = size(frange, 2);

cond = {'aloud'};
%cond = {'rest_ec'};
nc = size(cond,2);

atype{1} = 'ic';
%atype{2} = 'wpli';
%atype{3} = 'corr';
na = size(atype,2);

for i=1:na
    for j=1:nc
        for k=1:nf
            if (strcmp(atype{i}, 'wpli') || strcmp(atype{i}, 'ic'))
                IC_SMA_bs(EEG, cond{j}, frange(:,k), atype{i}, 60, alpha,1);
            else
                analyze_SMA(EEG, cond{j}, frange(:,k), atype{i}, 60, alpha,1);
            end
        end
    end
end

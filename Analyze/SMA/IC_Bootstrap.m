function [] = IC_Bootstrap(EEG)

alpha = .05;
% This does all the IC states and freq ranges

%IC_Bootstrap(EEG)

frange(:,1) = [128 156];
% frange(:,2) = [23 33];
% frange(:,3) = [62 73];
% frange(:,4) = [95 107];
% frange(:,5) = [125 165];
% frange(:,6) = [200 400];

nf = size(frange, 2);

cond = {'aloud', 'quiet', 'rest_eo', 'rest_ec'};
%cond = {'rest_ec'};
nc = size(cond,2);

for j=1:nc
    for k=1:nf
        %IC_SMA_bs(EEG, cond{j}, frange(:,k), 'ic', 60, alpha,1);
        IC_SMA_bs(EEG, cond{j}, frange(:,k), 'wpli', 60, alpha,1);
    end
end


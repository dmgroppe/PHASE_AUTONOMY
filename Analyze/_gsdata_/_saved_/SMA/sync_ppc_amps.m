function [amps] = sync_ppc_amps(pbins, rho)

% Fits cosines to the rho for all the frequencies that are passed to it
% sorting of this can be done afterwards

nfreqs = size(rho,1);

for i=1:nfreqs

    y = rho(i,:);
    %y = y - min(y);
    %y(find(y<0)) = 0;
    beta = nlinfit(pbins,y,@cos_fit,[0 1]);

    pfit = cos_fit(beta,pbins);
    %plot(pbins,y,pbins, pfit);
    amps(i) = abs(max(pfit)-min(pfit));
    
    %if beta(2) < 0
    %    amps(i) = -amps(i);
    %end     
end
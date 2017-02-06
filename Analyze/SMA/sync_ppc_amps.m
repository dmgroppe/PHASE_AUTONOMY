function [amps, pf] = sync_ppc_amps(pbins, rho)

% Fits cosines to the rho for all the frequencies that are passed to it
% sorting of this can be done afterwards

nfreqs = size(rho,1);
ffunc = @cos_fit;
beta0 = [1 0];

for i=1:nfreqs

    y = rho(i,:);
    %y = y + min(y);
    %y(find(y<0)) = 0;
    
    beta = nlinfit(pbins,y,ffunc,beta0);
    pfit(:,i) = ffunc(beta,pbins);
    
    %plot(pbins,y,pbins, pfit);
    amps(i) = abs(max(pfit(:,i))-min(pfit(:,i)));
    
    pf(:,i) = ffunc(beta,min(pbins):0.1:max(pbins));
    
    
%     clf
%     hold on;
%     plot(pbins,y, '.', 'LineStyle', 'None');
%     plot(pbins,pfit)
%     hold off;
    
    %if beta(2) < 0
    %    amps(i) = -amps(i);
    %end     
end
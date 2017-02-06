function [ppc_corr] = sync_ppc_lag(h1, h2, wind_length, plags)

% Computes Cross-correlation anaylsis as described in Womdelsdorf 2007
% Compute the devaitions from for "good" mean phase

dphi = phase_diff(angle(h1)-angle(h2));
a1 = abs(h1);
a2 = abs(h2);
mean_phase =circ_mean(dphi);
npoints = length(dphi);


for i=1:npoints-wind_length
    wdphi = dphi(i:(i+wind_length-1));
    sliding_mp(i) = cos(phase_diff(circ_mean(wdphi)-mean_phase));
    sliding_pcorr(i) = corr(a1(i:(i+wind_length-1))',a2(i:(i+wind_length-1))','type','Spearman');
end


% Correlation of the power correlation to the goodness of the phase for
% diffrent lags
count = 0;

for i=plags
    count = count + 1;
    pl = abs(i);
    
    if i == 0
        x1 = sliding_mp;
        x2 = sliding_pcorr;
        
    elseif i < 0
        x1 = sliding_mp(1:end-pl);
        x2 = sliding_pcorr(pl+1:end);
    else
        x1 = sliding_mp(pl+1:end);
        x2 = sliding_pcorr(1:end-pl);
    end
    
    [ppc_corr(count), ~] = corr(x1',x2','type','Spearman');  
end




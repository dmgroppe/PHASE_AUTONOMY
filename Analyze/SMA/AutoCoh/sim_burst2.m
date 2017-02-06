function [surr burst_ts Rburst] = sim_burst2(R, EEG, ap, freqs)

% Scramble the pahses for the rest state
[sstart send] = get_samples(EEG,'rest_eo',ap,EEG.ptname);
if isfield(EEG, 'cgt')
    rest = EEG.data(sstart:send);
else
    rest = EEG.data(ch, sstart:send);
end

[rest_surr,~]=IAAFT(rest,1);
surr = rest_surr;
burst_ts = zeros(1,length(surr))';
%surr = zeros(1,length(rest))';

x = -1:1/EEG.srate:1;
ts_length = length(rest);
offset = length(x);


for i=1:length(ap.autocoh.freq_add)
    fi = find(freqs == ap.autocoh.freq_add(i));
    nbursts = length(R.bursts{fi});
    b_loc = 1;
    bcount = 0;
    for j=1:1e18
        blength = R.lengths{fi}(randi(nbursts,1));
        bamp = abs(R.amps{fi}(randi(nbursts,1)));
        
        burst = real(gabor_1D(x,0,freqs(fi),blength/EEG.srate/ap.autocoh.t_scale(i)));
        bterm = offset - max(find(burst > ap.autocoh.tol));
        burstt = burst(bterm:end-bterm)/max(burst)*bamp*ap.autocoh.amp_scale(i);
        burst_length = length(burstt);
        polap = fix(burst_length*ap.autocoh.olap);
        
        if (b_loc + burst_length-polap) > length(surr)
            break;
        else

            
            if (b_loc - polap) > 0
                b_loc = b_loc - polap;
            end
            
            burst_ts(b_loc:(b_loc+burst_length-1)) = burst_ts(b_loc:(b_loc+burst_length-1)) + burstt';
            b_loc = b_loc + burst_length;
            bcount = bcount + 1;
            blengths(bcount) = burst_length;
        end
    end
    bcounts(i) = bcount;
    burst_lengths{i} = blengths;
end

surr = surr + burst_ts;
Rburst.bcounts = bcounts;
Rburst.burst_lengths = burst_lengths;
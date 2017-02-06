function [surr] = sim_burst1(R, EEG, ap, freqs)

% Scramble the pahses for the rest state
[sstart send] = get_samples(EEG,'rest_eo',ap,EEG.ptname);
if isfield(EEG, 'cgt')
    rest = EEG.data(sstart:send);
else
    rest = EEG.data(ch, sstart:send);
end

[rest_surr,~]=IAAFT(rest,1);
surr = rest_surr;
%surr = zeros(1,length(rest))';

x = -1:1/EEG.srate:1;
ts_length = length(rest);
offset = length(x);


for i=1:length(ap.autocoh.freq_add)
    fi = find(freqs == ap.autocoh.freq_add(i));
    nbursts = length(R.bursts{fi});
    blengths = R.lengths{fi}(randperm(nbursts));
    bamps = abs(R.amps{fi}(randperm(nbursts)));
    surr_nbursts = fix(nbursts*ap.autocoh.bfrac(i)) + randi(fix(nbursts*ap.autocoh.bfrac(i)),1);
    for j=1:surr_nbursts
        burst = real(gabor_1D(x,0,freqs(fi),blengths(j)/EEG.srate/ap.autocoh.t_scale(i)));
        burst = burst/max(burst)*bamps(j)*ap.autocoh.amp_scale(i);
        b_loc = abs(randi(ts_length));
        if b_loc > ts_length-offset
            b_loc = b_loc-offset;
        elseif b_loc < offset
            b_loc = b_loc+offset;
        end

        blocs(j) = b_loc;
        istart = fix(b_loc-offset/2);
        if istart < 0
            istart = 0;
        end
        surr(istart:(istart+offset-1)) = surr(istart:(istart+offset-1)) + burst';
    end
end
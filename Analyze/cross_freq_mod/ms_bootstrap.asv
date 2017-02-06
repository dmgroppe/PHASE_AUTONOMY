%   USAGE: [p] = ms_bootstrap(R1, aparams)
%   
%   Input:
%       R1: condition 1 spectra
%       atype:  analysis type 'power', 'cvar'
%       aparams, dparams: self explanatory
%   Output:
%       pinc:   Probability of z0 being greater than baseline by chance
%       pdec:   Probability of z0 being less than the baseline by chance


function [pinc pdec] = ms_bootstrap(R, aparams)

nsurr = aparams.ana.nsurr;
dparams = R.params;
nfrq = length(get_scales(aparams, dparams.data.srate));


% Get the test statistic
z0 = get_ms(R, aparams);
pinc = zeros(nfrq, nfrq);
pdec = pinc;
z = zeros(nfrq, nfrq, nsurr);

for i=1:nsurr
    % Get test statistic for each permutation
    z(:,:,i) = get_ms(R, aparams, 1);
end

for i=1:nsurr  
    ind = find(z(:,:,i) > z0);
    pinc(ind) = pinc(ind) + 1;
    
    ind = find( z0 > z(:,:,i));
    pdec(ind) = pdec(ind) + 1;
end

pinc = (1+pinc)./(nsurr+1);
pdec = (1+pdec)./(nsurr+1);


function [ms, frq] = get_ms(R, aparams, sp)

if (nargin < 3); sp = 0; end;

nepochs = size(R.data,1);
srate = R.params.data.srate;

for i=1:nepochs
    ts = R.padded_data(i,:);
    if (sp)
        ts = scramble_phase(ts);
    end
    [ws,frq] = twt(ts, srate, get_scales(aparams, srate), aparams.wlt.bw);
    spectra(:,:,i) = strip_padding(ws, R.alimit_list{i},R.params, 1);
end
[~, ms] = cross_freq_mod(spectra);
function [stripped] = strip_padding(padded_data, alimit, dparams, strip_baseline)

if (nargin < 3); strip_baseline = 0; end;
ndim = ndims(padded_data);

base_line_samples = time_to_samples(dparams.ana.baseline, dparams.data.srate);


if (strip_baseline)
    dstart = alimit.prefix;
else
    dstart = alimit.prefix - base_line_samples;
end
dend = alimit.prefix+(alimit.ep_end-alimit.ep_start)-1;

if (ndim == 2)
    stripped = padded_data(:,dstart:dend);
else
    stripped = padded_data(:,dstart:dend,:);
end


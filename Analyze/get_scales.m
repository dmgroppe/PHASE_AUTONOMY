% USAGE: function [scales] = get_scales(params, sr)
%   Return the scales to send to twt
%  fstart and fend - start and end frequencies
%   sr = sampling rate

function [scales] = get_scales(params, sr)

if (strcmp(params.tf.scale_type,'linear'))
    scales = linear_scale(params.tf.fstart:params.tf.finc:params.tf.fend, sr);
else
    scales = log_scale(params.tf.scale_start, params.tf.noctaves, params.tf.nvoices);
end
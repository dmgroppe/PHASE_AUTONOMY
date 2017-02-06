function [T, X] = get_cond_timeseries(data_ap, ap)

[fpaths, path_okay] = check_files(data_ap, '.abf');

if ~path_okay
    display('Unable to find some of the files.')
    display(sprintf('Exiting %s.', mfilename()));
    T = {};
    X = {};
    return;
end

ncond = numel(data_ap.cond.names);

for i=1:ncond
    % Get the data
    [t,x, ~] = get_sl_data(fpaths{i}, data_ap.cond.fname{i}, data_ap.ch, ap.srate, data_ap.cond.times(:,i), ap.load_mat);
   
    X{i} = x;
    T{i} = t;
end
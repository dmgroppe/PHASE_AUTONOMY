function [] = RunLyAnalysis()

clear;

params = get_default_params();

params.ana.subjectname = 'Ly';
params.ana.test = 'enc';
params.ana.cond = 'R';
trig_plot = '';

[params] = set_file_names(params);
%params.ana.chlist = [1 7 9];
params.ana.chlist = [1];

params.export.export_results = 1;

if (strcmp(params.ana.test, 'enc'))
    
    if (strcmp(params.ana.cond, 'sH'))
        % This is his sH epochs
        params.ana.epoch_list = [5 7 8 11 18 20 23 24 33 37 39 42 43 46 51 52 56 57 59];
    else
        % These are his R epochs
        params.ana.epoch_list = [4 6 14 15 16 17 21 29 34 35 36 38 44 48 50 53 54 55 58];
    end
    
    params.trig.get_from_file = 0;
    params.trig.dir = 'pos';
    params.trig.offset = 1;
    params.trig.baseline = 100;
    params.trig.threshold = 1.0e5;
    params.trig.plot = trig_plot;
    
else

    if (strcmp(params.ana.cond, 'Hits'))
        % This is his sH epochs
        params.ana.epoch_list = [7 8 12 14 17 18 25 30 33 38 41 42 43 44 47 48 56 59 60];
    else
        % These are his R epochs
        params.ana.epoch_list = [10 16 19 23 24 26 27 28 29 31 32 34 36 37 39 40 51 53 58];
    end
    
    params.trig.get_from_file = 0;
    params.trig.dir = 'pos';
    params.trig.offset = 1;
    params.trig.baseline = 100;
    params.trig.threshold = 1.0e5;
    params.trig.plot = trig_plot;
end

params.ana
params.trig


if (continue_prompt())
    analyze(params);
else
    display('Aborting.');
end
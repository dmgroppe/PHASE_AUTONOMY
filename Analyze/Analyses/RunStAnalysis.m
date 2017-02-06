function [] = RunStAnalysis(test, cond)

params = get_default_params();

params.ana.subjectname = 'St';
params.ana.test = test;
params.ana.cond = cond;
trig_plot = '';

[params] = set_file_names(params);
%params.ana.chlist = [1 7 9];
params.ana.chlist = [1 7 9];

params.export.export_results = 1;

if (strcmp(params.ana.test, 'enc'))
    
    if (strcmp(params.ana.cond, 'sH'))
        % This is his sH epochs
        params.ana.epoch_list = [1 4 5 9 11 14 16 18 21 22 24 27 31 32 33 44 45 46 53 54 58 59 60];
    else
        % These are his R epochs
        params.ana.epoch_list = [8 10 12 13 15 17 19 20 23 25 28 30 36 39 41 42 43 47 48 49 55 56 57];
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
        params.ana.epoch_list = [2 3 4 7 12 15 17 19 20 21 24 25 27 29 30 34 38 48 49 50 53 57 58];
    else
        % These are his R epochs
        params.ana.epoch_list = [6 11 13 16 18 22 26 28 32 33 36 37 41 42 44 45 47 52 54 55 56 60];
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

if (params.debug.prompt)
    if (continue_prompt())
        analyze(params);
    else
        display('Aborting.');
    end
else
    analyze(params);
end
    
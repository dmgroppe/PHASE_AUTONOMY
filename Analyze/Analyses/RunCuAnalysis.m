function [] = RunCuAnalysis(test, cond)

params = get_default_params();

params.ana.subjectname = 'Cu';
params.ana.test = test;
params.ana.cond = cond;
trig_plot = 'plot';

[params] = set_file_names(params);
%params.ana.chlist = [1 7 9];
params.ana.chlist = [1 7 9];

params.export.export_results = 1;

if (strcmp(params.ana.test, 'enc'))
    
    if (strcmp(params.ana.cond, 'sH'))
        % This is his sH epochs
        params.ana.epoch_list = [1 5 6 8 11 12 16 17 18 19 20 22 24 25 26 27 28 29 32 33 41 45 50 55 56];
    else
        % These are his R epochs
        params.ana.epoch_list = [3 7 9 13 14 15 23 30 31 34 35 36 37 38 39 40 42 43 46 48 52 54 57 59 60];
    end
    
    params.trig.get_from_file = 1;
    params.trig.dir = 'pos';
    params.trig.offset = 1;
    params.trig.baseline = 100;
    params.trig.threshold = 1.0e5;
    params.trig.plot = trig_plot;
    
else

    if (strcmp(params.ana.cond, 'Hits'))
        % This is his sH epochs
        params.ana.epoch_list = [3 4 6 8 9 10 23 24 26 29 33 34 36 37 40 41 43 45 48 51 53 54 56 58 59];
    else
        % These are his R epochs
        params.ana.epoch_list = [1 2 7 12 13 14 15 16 17 18 19 20 21 22 27 28 32 35 38 42 44 46 47 49 55];
    end
    
    params.trig.get_from_file = 1;
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
function [] = RunSiAnalysis(test, cond)

params = get_default_params();

params.ana.subjectname = 'Si';
params.ana.test = test;
params.ana.cond = cond;
trig_plot = '';

[params] = set_file_names(params);
%params.ana.chlist = [36 41 43];
params.ana.chlist = [36 41 43];

params.export.export_results = 1;

if (strcmp(params.ana.test, 'enc'))
    
    if (strcmp(params.ana.cond, 'sH'))
        % This is his sH epochs
        params.ana.epoch_list = [6 14 16 20 24 26 29 32 34 36 37 39 41 43 44 47 49 51 52 53 54 55 59];
    else
        % These are his R epochs
        params.ana.epoch_list = [5 9 10 11 13 15 17 18 19 23 25 27 31 35 38 40 42 45 50 56 57 58 60];
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
        params.ana.epoch_list = [2 7 10 12 13 15 21 23 25 29 30 31 35 37 38 40 42 43 45 50 52 56 58];
    else
        % These are his R epochs
        params.ana.epoch_list = [1 3 5 6 14 18 20 22 24 26 32 36 39 44 46 47 48 49 53 54 55 59 60];
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